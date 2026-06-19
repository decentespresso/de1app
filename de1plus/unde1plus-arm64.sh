#!/bin/bash

# Launch de1plus with the NATIVE Apple Silicon (arm64) build of undroidwish.
# Companion to unde1plus.sh, which uses the x86_64 (Rosetta) undroidwish.
#
# Requires /usr/local/bin/undroidwish-arm64 (symlink to
# /Applications/undroidwish-arm64.app/Contents/MacOS/undroidwish-arm64).

# Change working directory for this script to its parent directory so that it
# can be called from anywhere.
cd "$(dirname "$0")"

#export SDL_VIDEODRIVER=jsmpeg
#export SDL_VIDEO_JSMPEG_OUTFILE=~/Desktop/decent.mpg
undroidwish-arm64 de1plus.tcl -sdlheight 801 -sdlwidth 1280 -sdlrootheight 800 -sdlrootwidth 1280 -name Decent
#undroidwish-arm64 de1plus.tcl -sdlheight 1600 -sdlwidth 2560 -sdlrootheight 1600 -sdlrootwidth 2560 -name Decent -sdlresizable
