#!/bin/bash
#
# make_osx_arm64_signed.sh — build a Developer-ID-signed, NOTARIZED, arm64
# Decent.app and emit it as a .zip. Called by misc/makede1.tcl for the arm64
# OSX build (the x86 build just zips the committed skeleton unsigned).
#
# WHY this lives at the de1app repo ROOT (not in misc/): the nightly/beta/stable
# builders run `git -C misc clean -xdf`, which deletes every untracked file in
# misc/ BEFORE makede1.tcl runs. An arm64 skeleton or helper placed in misc/
# would be wiped each build. So we build the arm64 .app on the fly here, from:
#   - the git-TRACKED x86 skeleton (launchers / Info.plist / icons) in
#     misc/desktop_app/osx/Decent.app  — minus its stale x86 wish, and
#   - a NATIVE arm64, Developer-ID-signed, hardened-runtime, NOTARIZABLE wish
#     (undroidwish-arm64 — the `ebuild` __TEXT,__zipfs build; the appended-zip
#     variant FAILS codesign --strict and cannot be notarized), and
#   - the curated de1plus distribution payload (materialised, not symlinked).
#
# Usage:
#   make_osx_arm64_signed.sh <de1plus_src_dir> <output_zip>
# e.g. (from makede1.tcl):
#   make_osx_arm64_signed.sh /d/download/sync/de1nightly \
#       /d/download/desktop/de1nightly/osx_arm64/decent_osx_arm64.zip
#
# Env overrides:
#   DECENT_ARM64_WISH=<path>   interpreter to bundle (default: resolved from
#                              `undroidwish-arm64` on PATH)
#   SIGN_ID=<id>               codesign identity (default: Vid Tadel Developer ID)
#   NOTARY_PROFILE=<name>      notarytool --keychain-profile (default: bping-notary)
#   SKIP_NOTARIZE=1            sign only; skip the notarize+staple round-trip
#
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "usage: $0 <de1plus_src_dir> <output_zip>" >&2
    exit 2
fi
SRC_DE1PLUS="$1"
OUT_ZIP="$2"

REPO="/d/admin/code/de1app"
SKEL="$REPO/misc/desktop_app/osx/Decent.app"          # git-tracked skeleton
SIGN_ID="${SIGN_ID:-Developer ID Application: Vid Tadel (XLS3XF57J8)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-bping-notary}"

[ -d "$SKEL" ]        || { echo "ERROR: skeleton not found: $SKEL" >&2; exit 1; }
[ -d "$SRC_DE1PLUS" ] || { echo "ERROR: de1plus payload not found: $SRC_DE1PLUS" >&2; exit 1; }

# --- 1. Resolve the native-arm64, notarizable interpreter -------------------
# Prefer an explicit override, then the copy committed in the repo (so the build
# is self-contained like the other platforms' undroidwish binaries), then PATH.
COMMITTED_WISH="$REPO/misc/desktop_app/osx_arm64/undroidwish-arm64"
if [ -n "${DECENT_ARM64_WISH:-}" ]; then
    WISH="$DECENT_ARM64_WISH"
elif [ -x "$COMMITTED_WISH" ]; then
    WISH="$COMMITTED_WISH"
else
    RAW="$(command -v undroidwish-arm64)" || {
        echo "ERROR: undroidwish-arm64 not found (no committed copy at $COMMITTED_WISH, not on PATH; set DECENT_ARM64_WISH=...)" >&2; exit 1; }
    WISH="$(readlink -f "$RAW" 2>/dev/null || perl -MCwd -le 'print Cwd::abs_path(shift)' "$RAW")"
fi
[ -x "$WISH" ] || { echo "ERROR: interpreter not found/executable: $WISH" >&2; exit 1; }
# It MUST pass strict validation, or notarization will reject it.
if ! codesign --verify --strict "$WISH" 2>/dev/null; then
    echo "ERROR: $WISH fails 'codesign --verify --strict' — not notarizable." >&2
    echo "       Use the ebuild (__zipfs) undroidwish-arm64, not the appended-zip build." >&2
    exit 1
fi
echo "Interpreter : $WISH"
echo "Output zip  : $OUT_ZIP"
echo "Sign identity: $SIGN_ID"

# --- 2. Stage the bundle (outside misc/, in a temp dir) ---------------------
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/decent_arm64.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
APP="$STAGE/Decent.app"

echo "Staging app skeleton ..."
rsync -a --delete \
    --exclude 'Contents/Resources/de1plus' \
    --exclude 'Contents/MacOS/wish' \
    "$SKEL/" "$APP/"

mkdir -p "$APP/Contents/MacOS"
cp "$WISH" "$APP/Contents/MacOS/wish"
chmod +x "$APP/Contents/MacOS/wish"

echo "Materialising de1plus payload ..."
RES="$APP/Contents/Resources/de1plus"
mkdir -p "$RES"
rsync -aL --delete \
    --exclude 'CVS' --exclude '.git' --exclude '.gitignore' \
    --exclude '.DS_Store' \
    "$SRC_DE1PLUS/" "$RES/"

# Entitlement the wish process needs: it dlopen()s the 4 optional extensions
# from /opt/homebrew/lib, which the hardened runtime's library validation would
# otherwise block.
ENT="$STAGE/decent_arm64.entitlements"
cat > "$ENT" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
</dict>
</plist>
PLIST

# --- 3. Sign nested code, inside-out ----------------------------------------
# Every nested Mach-O must be Developer-ID + hardened-runtime signed before the
# outer bundle is sealed; otherwise the notary service rejects the submission.
HARDEN=(--force --options runtime --timestamp --sign "$SIGN_ID")

# 3a. The BLE helper (path-bound TCC identity). Re-sign only if it is not
#     already a valid Dev-ID + hardened-runtime signature, so a normal build
#     keeps the committed signature (and the user's Bluetooth grant).
HELPER="$RES/ble/bin/ble_helper"
if [ -f "$HELPER" ]; then
    chmod +x "$HELPER"
    if codesign -dvv "$HELPER" 2>&1 | grep -q "Authority=Developer ID Application: Vid Tadel" \
       && codesign -dvv "$HELPER" 2>&1 | grep -q "flags=.*runtime" \
       && codesign --verify --strict "$HELPER" 2>/dev/null; then
        echo "ble_helper  : already Dev-ID + hardened — kept."
    else
        echo "ble_helper  : (re)signing ..."
        codesign "${HARDEN[@]}" --identifier com.decentespresso.ble-helper "$HELPER"
    fi
else
    echo "WARNING: $HELPER missing — Bluetooth will not work in this build." >&2
fi

# 3b. Any other nested Mach-O (dylibs/.so/executables) the payload might gain.
#     `wish` is re-signed separately below (step 3d).
while IFS= read -r m; do
    [ "$m" = "$APP/Contents/MacOS/wish" ] && continue
    [ "$m" = "$HELPER" ] && continue
    echo "sign nested : ${m#$APP/}"
    codesign "${HARDEN[@]}" "$m"
done < <(find "$APP" -type f \( -perm -u+x -o -name '*.dylib' -o -name '*.so' \) \
            -exec sh -c 'file "$1" | grep -q "Mach-O" && echo "$1"' _ {} \;)

# 3c. The secondary launcher scripts in Contents/MacOS (unde1plus.sh,
#     decent_webcast.sh, and the `undroidwish` launcher). codesign treats every
#     file in MacOS/ as nested code, so an unsigned script fails `--verify
#     --deep` and breaks Gatekeeper. Sign them all; `wish` keeps its own sig.
for s in "$APP/Contents/MacOS/"*; do
    [ -f "$s" ] || continue
    [ "$s" = "$APP/Contents/MacOS/wish" ] && continue
    echo "sign script : ${s#$APP/}"
    codesign "${HARDEN[@]}" "$s"
done

# 3d. The wish Mach-O. Re-sign in place (rather than trusting the standalone
#     binary's pre-existing signature, whose embedded Info.plist context is
#     invalid once relocated into this bundle) with the library-validation
#     entitlement it needs at runtime.
echo "sign wish   : Contents/MacOS/wish"
codesign "${HARDEN[@]}" --entitlements "$ENT" "$APP/Contents/MacOS/wish"

# --- 4. Seal the outer bundle -----------------------------------------------
# The bundle's CFBundleExecutable is the `undroidwish` launcher script; the real
# Mach-O (`wish`) is nested and already hardened. Sign the bundle last, without
# --deep (nested code is already signed above).
echo "Signing bundle ..."
codesign --force --options runtime --timestamp --sign "$SIGN_ID" "$APP"
codesign --verify --deep --strict --verbose=2 "$APP"

# --- 5. Notarize + staple ----------------------------------------------------
if [ "${SKIP_NOTARIZE:-0}" = "1" ]; then
    echo "SKIP_NOTARIZE=1 — skipping notarization/stapling."
else
    echo "Notarizing (this contacts Apple; ~2-5 min) ..."
    NZIP="$STAGE/notarize.zip"
    ditto -c -k --keepParent "$APP" "$NZIP"
    xcrun notarytool submit "$NZIP" --keychain-profile "$NOTARY_PROFILE" --wait
    echo "Stapling ..."
    xcrun stapler staple "$APP"
    spctl --assess --type execute -vv "$APP" 2>&1 | sed 's/^/  spctl: /' || true
fi

# --- 6. Emit the final zip ---------------------------------------------------
mkdir -p "$(dirname "$OUT_ZIP")"
rm -f "$OUT_ZIP"
# ditto (not zip) preserves the bundle signature + stapled ticket faithfully.
ditto -c -k --keepParent "$APP" "$OUT_ZIP"
echo "Done: $OUT_ZIP"
