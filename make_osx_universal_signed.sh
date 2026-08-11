#!/bin/bash
#
# make_osx_universal_signed.sh — build ONE Developer-ID-signed, NOTARIZED,
# UNIVERSAL (arm64 + x86_64) Decent.app and emit it as a .zip or .dmg.
#
# This supersedes shipping two separate OSX apps (an unsigned x86 zip + a signed
# arm64 zip). It bundles a single universal `wish` interpreter — a `lipo` of the
# two `ebuild` (__TEXT,__zipfs) undroidwish binaries — so one download runs
# native on Apple Silicon AND Intel, with no Gatekeeper "damaged" warning on
# either.
#
# WHY a universal wish and not the stock x86 undroidwish: the stock x86
# interpreter carries an APPENDED zip VFS (data after the Mach-O), which
# `codesign --strict` rejects and Apple's notary service refuses. Only the
# `ebuild` build, which embeds the VFS as a real __TEXT,__zipfs Mach-O section,
# can be signed + notarized. Each arch slice keeps its own __zipfs; this script
# verifies that before sealing.
#
# Build the two inputs first:
#   arm64 : ~/iwish/build-uw-arm64/undroidwish   (already built)
#   x86_64: ~/iwish/build-uw-x86/undroidwish     (~/iwish/build-uw-x86.sh)
#
# Usage:
#   make_osx_universal_signed.sh <de1plus_src_dir> <output_zip_or_dmg>
# e.g.:
#   make_osx_universal_signed.sh /d/download/sync/de1nightly \
#       /d/download/desktop/de1nightly/osx_universal/decent_osx.zip
#   make_osx_universal_signed.sh de1plus ~/Desktop/Decent.dmg
#
# Env overrides:
#   DECENT_ARM64_WISH=<path>   arm64 ebuild interpreter (default: committed copy,
#                              else ~/iwish/build-uw-arm64/undroidwish, else PATH)
#   DECENT_X86_WISH=<path>     x86_64 ebuild interpreter (default:
#                              ~/iwish/build-uw-x86/undroidwish)
#   SIGN_ID=<id>               codesign identity (default: Vid Tadel Developer ID)
#   NOTARY_PROFILE=<name>      notarytool --keychain-profile (default: bping-notary)
#   SKIP_NOTARIZE=1            sign only; skip the notarize+staple round-trip
#
set -euo pipefail

REPO="/d/admin/code/de1app"
SKEL="$REPO/misc/desktop_app/osx/Decent.app"          # git-tracked skeleton (arch-neutral launchers/plist/icons)
SIGN_ID="${SIGN_ID:-Developer ID Application: Vid Tadel (XLS3XF57J8)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-bping-notary}"

# macOS-only build (lipo/codesign/notarytool/stapler/hdiutil). The resulting
# signed + notarized .app is committed to misc/osx and served VERBATIM by the
# Linux nightly host -- no Apple tools on Linux. Nightly code freshness comes
# from the in-app self-updater (see osx.tcl / the minimal-seed note below), so
# this only needs re-running when the interpreter/helper changes.
#
# Channel is a build-time setting: DECENT_CHANNEL = nightly (default) | beta |
# stable. It picks the default payload sync dir AND is baked into the bundle so
# the minimal-seed first-run fill self-updates from the SAME channel.
DECENT_CHANNEL="${DECENT_CHANNEL:-nightly}"
case "$DECENT_CHANNEL" in
    nightly) CHAN_DIR=de1nightly ; CHAN_NUM=2 ;;
    beta)    CHAN_DIR=de1beta    ; CHAN_NUM=1 ;;
    stable)  CHAN_DIR=de1plus    ; CHAN_NUM=0 ;;
    *) echo "ERROR: DECENT_CHANNEL must be nightly|beta|stable (got '$DECENT_CHANNEL')" >&2; exit 1 ;;
esac

if [ "$#" -gt 2 ]; then
    echo "usage: $0 [de1plus_src_dir] [output_zip_or_dmg]" >&2
    echo "       src defaults to /d/download/sync/$CHAN_DIR  (DECENT_CHANNEL=$DECENT_CHANNEL)" >&2
    echo "       output defaults to $REPO/misc/osx/Decent.zip" >&2
    exit 2
fi
SRC_DE1PLUS="${1:-/d/download/sync/$CHAN_DIR}"
OUT="${2:-$REPO/misc/osx/Decent.zip}"

[ -d "$SKEL" ]        || { echo "ERROR: skeleton not found: $SKEL" >&2; exit 1; }
[ -d "$SRC_DE1PLUS" ] || { echo "ERROR: de1plus payload not found: $SRC_DE1PLUS" >&2; exit 1; }

resolve() { readlink -f "$1" 2>/dev/null || perl -MCwd -le 'print Cwd::abs_path(shift)' "$1"; }

# --- 1. Resolve the two native ebuild interpreters --------------------------
# arm64: explicit override, then committed repo copy, then the build dir, then PATH.
if [ -n "${DECENT_ARM64_WISH:-}" ]; then
    ARM_WISH="$DECENT_ARM64_WISH"
elif [ -x "$REPO/misc/desktop_app/osx_arm64/undroidwish-arm64" ]; then
    ARM_WISH="$REPO/misc/desktop_app/osx_arm64/undroidwish-arm64"
elif [ -x "$HOME/iwish/build-uw-arm64/undroidwish" ]; then
    ARM_WISH="$HOME/iwish/build-uw-arm64/undroidwish"
else
    RAW="$(command -v undroidwish-arm64 || true)"
    [ -n "$RAW" ] || { echo "ERROR: no arm64 ebuild undroidwish found (set DECENT_ARM64_WISH=...)" >&2; exit 1; }
    ARM_WISH="$(resolve "$RAW")"
fi
# x86_64: explicit override, then the build dir. (NOT the committed skeleton wish
# — that is the appended-zip build with no __zipfs and cannot be notarized.)
X86_WISH="${DECENT_X86_WISH:-$HOME/iwish/build-uw-x86/undroidwish}"

[ -x "$ARM_WISH" ] || { echo "ERROR: arm64 interpreter not found/executable: $ARM_WISH" >&2; exit 1; }
[ -x "$X86_WISH" ] || { echo "ERROR: x86_64 interpreter not found/executable: $X86_WISH" >&2; echo "       Build it: ~/iwish/build-uw-x86.sh" >&2; exit 1; }

# Each input must be the right single arch and carry a __zipfs section, or the
# resulting universal binary won't be notarizable / won't find its VFS.
check_input() {
    local f="$1" want="$2"
    local got; got="$(lipo -archs "$f" 2>/dev/null || echo '?')"
    [ "$got" = "$want" ] || { echo "ERROR: $f is arch '$got', expected '$want'" >&2; exit 1; }
    otool -arch "$want" -l "$f" 2>/dev/null | grep -q '__zipfs' \
        || { echo "ERROR: $f ($want) has no __zipfs section — it's the appended-zip 'build', not 'ebuild'. Cannot notarize." >&2; exit 1; }
}
check_input "$ARM_WISH" arm64
check_input "$X86_WISH" x86_64

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/decent_universal.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT

# --- 2. lipo the universal interpreter --------------------------------------
UNI_WISH="$STAGE/wish-universal"
echo "lipo arm64 + x86_64 -> universal wish ..."
lipo -create "$ARM_WISH" "$X86_WISH" -output "$UNI_WISH"
echo "Universal wish archs: $(lipo -archs "$UNI_WISH")"
# Belt-and-suspenders: confirm BOTH slices kept their __zipfs after lipo.
for a in arm64 x86_64; do
    otool -arch "$a" -l "$UNI_WISH" | grep -q '__zipfs' \
        || { echo "ERROR: universal wish lost __zipfs in the $a slice" >&2; exit 1; }
done
echo "Both slices carry __zipfs."
echo "arm64 wish  : $ARM_WISH"
echo "x86_64 wish : $X86_WISH"
echo "Output      : $OUT"
echo "Sign id     : $SIGN_ID"

# --- 3. Stage the bundle ----------------------------------------------------
APP="$STAGE/Decent.app"
echo "Staging app skeleton ..."
rsync -a --delete \
    --exclude 'Contents/Resources/de1plus' \
    --exclude 'Contents/MacOS/wish' \
    "$SKEL/" "$APP/"

mkdir -p "$APP/Contents/MacOS"
cp "$UNI_WISH" "$APP/Contents/MacOS/wish"
chmod +x "$APP/Contents/MacOS/wish"

# --- 3b. Native launcher stub (REQUIRED for a notarized bundle) --------------
# CFBundleExecutable is "undroidwish"; the git skeleton ships it as a /bin/bash
# script. That launches fine while UNSIGNED, but once the bundle is hardened +
# notarized the OS tries to spawn /bin/bash as the app's main process, and macOS
# Launch Constraints REJECT a system binary as a bundle main executable
# ("AMFI: Launch Constraint Violation" / "Security policy would not allow
# process" -> the Finder dialog: 'The application "Decent.app" can't be
# opened.'). Fix: compile a tiny universal Mach-O that chdir()s to Contents and
# execs wish with the SAME de1plus args the script used, and install it AS the
# main executable (same name -> no Info.plist change). It is hardened-signed by
# step 4 below like any other Mach-O.
LSRC="$STAGE/launcher.c"
cat > "$LSRC" <<'CEOF'
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <stdio.h>
#include <mach-o/dyld.h>
/* NOTE: deliberately NOT using libgen dirname() — on macOS it can return a
 * pointer to shared static storage, so calling it twice clobbers the first
 * result. We slice the path by hand instead. */
int main(int argc, char **argv) {
    char exe[PATH_MAX]; uint32_t sz = sizeof(exe);
    if (_NSGetExecutablePath(exe, &sz) != 0) return 71;
    char macos[PATH_MAX];                          /* -> .../Contents/MacOS */
    if (!realpath(exe, macos)) { strncpy(macos, exe, sizeof(macos)-1); macos[sizeof(macos)-1] = 0; }
    char *s = strrchr(macos, '/');                 /* strip "/undroidwish" */
    if (!s) return 74; *s = 0;
    char contents[PATH_MAX];                        /* -> .../Contents */
    strncpy(contents, macos, sizeof(contents)-1); contents[sizeof(contents)-1] = 0;
    char *s2 = strrchr(contents, '/');             /* strip "/MacOS" */
    if (!s2) return 75; *s2 = 0;
    char wish[PATH_MAX];
    snprintf(wish, sizeof(wish), "%s/wish", macos);
    setenv("BLE_HELPER_NO_REEXEC", "1", 1);        /* match the old launcher */
    if (chdir(contents) != 0) return 73;
    char *args[] = { wish, "Resources/de1plus/de1plus.tcl",
        "-sdlheight", "801", "-sdlwidth", "1280",
        "-sdlrootheight", "800", "-sdlrootwidth", "1280",
        "-name", "DE1", NULL };
    execv(wish, args);
    perror("execv wish");
    return 72;
}
CEOF
echo "Compiling universal launcher stub -> Contents/MacOS/undroidwish ..."
cc -arch arm64 -arch x86_64 -mmacosx-version-min=10.13 -O2 -o "$APP/Contents/MacOS/undroidwish" "$LSRC"
chmod +x "$APP/Contents/MacOS/undroidwish"
echo "Launcher archs: $(lipo -archs "$APP/Contents/MacOS/undroidwish")"

echo "Materialising de1plus payload ..."
RES="$APP/Contents/Resources/de1plus"
mkdir -p "$RES"
rsync -aL --delete \
    --exclude 'CVS' --exclude '.git' --exclude '.gitignore' \
    --exclude '.DS_Store' \
    "$SRC_DE1PLUS/" "$RES/"

# --- Minimal seed -----------------------------------------------------------
# Keep only what the app needs to BOOT, so the committed misc/osx artifact stays
# small. On first launch osx.tcl nudges the in-app self-updater, which
# force-fetches every missing file into ~/Documents/de1app -- so the pruned
# files arrive there, not in the (immutable, notarized) bundle. Lists are
# pipe-delimited so names with spaces work; override via SEED_SKINS / SEED_FONTS.

# skins/ is the big one. Keep a few bootable skins, and within each keep only the
# 2560x1600 dir (the dui rescale base -> renders on ANY display) + 1280x800 (the
# common desktop size); the updater fills every other resolution on first run.
# That drops the bulk of each skin (its other-resolution image sets).
# MINIMAL_SEED=1 (default) prunes skins/fonts to a bootable subset and relies on
# the first-run self-updater to refill. MINIMAL_SEED=0 ships the COMPLETE curated
# misc.tcl set (the make_de1_dir manifest) so the bundle is fully self-contained.
if [ "${MINIMAL_SEED:-1}" = "1" ]; then
SEED_SKINS="${SEED_SKINS:-default|Insight|Insight Dark|Streamline|Streamline Dark|DSx2}"
SEED_SKIN_RES="${SEED_SKIN_RES:-2560x1600|1280x800}"
if [ -d "$RES/skins" ]; then
    pruned=0; trimmed=0
    for d in "$RES/skins"/*/; do
        name="$(basename "$d")"
        case "|$SEED_SKINS|" in
            *"|$name|"*)
                # kept skin: drop resolution subdirs not in SEED_SKIN_RES; leave
                # the skin's non-resolution files (skin.tcl, fonts, ...) untouched.
                for sub in "$d"*/; do
                    [ -d "$sub" ] || continue
                    subn="$(basename "$sub")"
                    case "$subn" in
                        [0-9]*x[0-9]*)
                            case "|$SEED_SKIN_RES|" in
                                *"|$subn|"*) : ;;
                                *) rm -rf "$sub"; trimmed=$((trimmed+1)) ;;
                            esac ;;
                    esac
                done ;;
            *) rm -rf "$d"; pruned=$((pruned+1)) ;;  # drop whole skin -> updater refills
        esac
    done
    echo "Minimal seed: kept skins [$SEED_SKINS] at res [$SEED_SKIN_RES]; pruned $pruned skins, $trimmed extra-res dirs."
fi

# fonts/ is ~64 MB but only a handful matter at boot (dui.tcl: the English UI
# faces + the FA Regular/Brands icon faces).
#
# ---------------------------------------------------------------------------
# NOTE (2026-07-10) -- applies to BOTH this OSX build AND the iOS/iWish minimal
# seed: dui.tcl NO LONGER falls back when the "global" font is missing (the
# `if {$global_font_name eq ""} { set global_font_name $helvetica_font }` guard
# was removed on purpose, so the shared code stays clean). The "global" style is
# built from the 16 MB NotoSansCJKjp-Regular.otf (dui.tcl, English branch). If a
# minimal seed OMITS it, add_or_get_familyname returns "" and every
# `-font global_font` widget -- notably the SKIN-CHOOSER listbox
# (de1_skin_settings.tcl) -- renders in Tk's ugly default font until the updater
# fetches the real font. So NotoSansCJKjp-Regular.otf is now KEPT in SEED_FONTS
# below (+16 MB, worth it for a clean skin chooser offline). The iOS/iWish minimal
# seed needs the same font kept (see ~/iwish/push-de1app.sh). Skin-local fonts ride
# along inside their skin dir, untouched.
# ---------------------------------------------------------------------------
SEED_FONTS="${SEED_FONTS:-notosansuiregular.ttf|notosansuibold.ttf|NotoSansCJKjp-Regular.otf|Font Awesome 5 Brands-Regular-400.otf|Font Awesome 6 Brands-Regular-400.otf|Font Awesome 5 Pro-Regular-400.otf|Font Awesome 6 Pro-Regular-400.otf}"
if [ -d "$RES/fonts" ]; then
    pruned=0
    for f in "$RES/fonts"/*; do
        [ -f "$f" ] || continue                     # leave any subdirs alone
        name="$(basename "$f")"
        case "|$SEED_FONTS|" in
            *"|$name|"*) : ;;                       # keep
            *) rm -f "$f"; pruned=$((pruned+1)) ;;   # drop -> self-updater refills
        esac
    done
    echo "Minimal seed: kept [$(echo "$SEED_FONTS" | tr '|' ' ' | wc -w | tr -d ' ')] boot fonts; pruned $pruned others."
fi
else
    echo "MINIMAL_SEED=0 — shipping the complete misc.tcl payload set (self-contained; no prune)."
fi

# Mark this as the notarized, immutable bundle. osx.tcl keys off this marker to
# redirect [homedir] to a writable ~/Documents/de1app on first launch, so the
# signed bundle is never written to (any write breaks its signature). MUST be
# created here, before signing, so it is sealed into the bundle. Deliberately
# NOT in misc.tcl's self-update file list: a normal in-place (non-notarized)
# build must never receive it, or it would wrongly redirect into Documents.
: > "$RES/notarized.flag"

# Enable the read-only write-guard (readonly_guard.tcl) in this TEST build: it
# logs + redirects any write that targets the frozen, notarized bundle, giving a
# canonical list of stragglers. Sealed in before signing; NOT in misc.tcl's update
# list. Remove for a release build once the offender list is clean.
: > "$RES/writeguard.flag"

# Bake the update channel so osx.tcl's first-run fill (and the running session)
# self-update from the SAME channel this package was built from. 0=stable
# 1=beta 2=nightly. Read by osx.tcl as [homedir]/osx_update_channel.
printf '%s\n' "$CHAN_NUM" > "$RES/osx_update_channel"
echo "Channel: $DECENT_CHANNEL (app_updates_beta_enabled=$CHAN_NUM), payload $SRC_DE1PLUS"

# Entitlement the wish process needs: it dlopen()s optional extensions from the
# homebrew prefix, which the hardened runtime's library validation would block.
ENT="$STAGE/decent_universal.entitlements"
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

# --- 4. Sign nested code, inside-out ----------------------------------------
HARDEN=(--force --options runtime --timestamp --sign "$SIGN_ID")

# 4a. The BLE helper (already universal; path-bound TCC identity). Re-sign only
#     if it is not already a valid Dev-ID + hardened-runtime signature.
HELPER="$RES/ble/bin/ble_helper.bin"
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

# 4b. Any other nested Mach-O (dylibs/.so/executables) the payload carries —
#     e.g. ble/lib/libtclble.dylib. `wish` is re-signed separately (step 4d).
while IFS= read -r m; do
    [ "$m" = "$APP/Contents/MacOS/wish" ] && continue
    [ "$m" = "$APP/Contents/MacOS/undroidwish" ] && continue   # main executable — signed last (step 4e)
    [ "$m" = "$HELPER" ] && continue
    echo "sign nested : ${m#$APP/}"
    codesign "${HARDEN[@]}" "$m"
done < <(find "$APP" -type f \( -perm -u+x -o -name '*.dylib' -o -name '*.so' \) \
            -exec sh -c 'file "$1" | grep -q "Mach-O" && echo "$1"' _ {} \;)

# 4c. Secondary launcher scripts in Contents/MacOS — codesign treats every file
#     in MacOS/ as nested code, so unsigned ones break Gatekeeper.
for s in "$APP/Contents/MacOS/"*; do
    [ -f "$s" ] || continue
    [ "$s" = "$APP/Contents/MacOS/wish" ] && continue
    [ "$s" = "$APP/Contents/MacOS/undroidwish" ] && continue   # main executable — signed last (step 4e)
    echo "sign script : ${s#$APP/}"
    codesign "${HARDEN[@]}" "$s"
done

# 4d. The universal wish Mach-O. Re-sign in place (both slices) with the
#     library-validation entitlement it needs at runtime.
echo "sign wish   : Contents/MacOS/wish (universal)"
codesign "${HARDEN[@]}" --entitlements "$ENT" "$APP/Contents/MacOS/wish"

# 4e. The MAIN executable (the launcher stub, CFBundleExecutable=undroidwish) —
#     sign LAST, after every other Contents/MacOS component, so codesign does not
#     reject it for having unsigned siblings. It just execs wish, so it needs no
#     entitlements of its own.
echo "sign main   : Contents/MacOS/undroidwish (launcher, universal)"
codesign "${HARDEN[@]}" "$APP/Contents/MacOS/undroidwish"

# --- 5. Seal the outer bundle -----------------------------------------------
echo "Signing bundle ..."
codesign --force --options runtime --timestamp --sign "$SIGN_ID" "$APP"
codesign --verify --deep --strict --verbose=2 "$APP"

# --- 6. Notarize + staple ----------------------------------------------------
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

# --- 7. Emit the final artifact (.zip, .dmg, or .app) -----------------------
mkdir -p "$(dirname "$OUT")"
rm -rf "$OUT"
case "$OUT" in
    *.zip)
        # ditto (not zip) preserves the bundle signature + stapled ticket.
        ditto -c -k --keepParent "$APP" "$OUT"
        ;;
    *.dmg)
        DSTAGE="$STAGE/dmg"; mkdir -p "$DSTAGE"
        ditto "$APP" "$DSTAGE/Decent.app"
        ln -s /Applications "$DSTAGE/Applications"
        # Detach any stale "Decent" volume still mounted (e.g. from inspecting a
        # previous $OUT), else `hdiutil create` fails "Resource busy".
        for _v in "/Volumes/Decent" /Volumes/Decent\ *; do
            [ -e "$_v" ] && hdiutil detach "$_v" -force >/dev/null 2>&1 || true
        done
        hdiutil create -volname "Decent" -srcfolder "$DSTAGE" \
            -fs HFS+ -format UDZO -ov "$OUT" >/dev/null
        # Sign + notarize + staple the DMG container itself. The .app inside is
        # already notarized+stapled; doing the DMG too makes the download trusted
        # with no Gatekeeper prompt or "verifying..." delay.
        codesign --force --timestamp --sign "$SIGN_ID" "$OUT"
        if [ "${SKIP_NOTARIZE:-0}" != "1" ]; then
            echo "Notarizing the DMG (contacts Apple; ~2-5 min) ..."
            xcrun notarytool submit "$OUT" --keychain-profile "$NOTARY_PROFILE" --wait
            xcrun stapler staple "$OUT"
            spctl --assess --type open --context context:primary-signature -vv "$OUT" 2>&1 | sed 's/^/  spctl-dmg: /' || true
        fi
        ;;
    *.app)
        ditto "$APP" "$OUT"
        ;;
    *)
        echo "ERROR: unknown output type for '$OUT' (use .zip, .dmg, or .app)" >&2
        exit 1
        ;;
esac
echo "Done: $OUT  ($(du -h "$OUT" | cut -f1))"
file "$OUT" 2>/dev/null || true
echo "Universal wish slices: $(lipo -archs "$APP/Contents/MacOS/wish" 2>/dev/null || true)"
