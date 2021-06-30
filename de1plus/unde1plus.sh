#!/bin/bash

# Change working directory for this script to its parent directory so that it
# can be called from anywhere.
cd "$(dirname "$0")"

# You should put undroidwish into your path to have this script work
# 
# On Mac OSX, you can for example do this this:
# 
# sudo ln -s /Applications/undroidwish.app/Contents/MacOS/undroidwish /usr/local/bin/.

#export SDL_VIDEODRIVER=jsmpeg
#export SDL_VIDEO_JSMPEG_OUTFILE=~/Desktop/decent.mpg
undroidwish de1plus.tcl  -sdlheight 800 -sdlwidth 1280 -sdlrootheight 800 -sdlrootwidth 1280 -name Decent -sdlresizable
#undroidwish de1plus.tcl  -sdlheight 1600 -sdlwidth 2560 -sdlrootheight 1600 -sdlrootwidth 2560 -name Decent -sdlresizable

