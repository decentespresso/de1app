#!/bin/bash

echo OBSOLETE
exit

cd 2560x1600
convert nothing_on.png -resize 1280x800!  ../1280x800/nothing_on.png
convert espresso_on.png -resize 1280x800!  ../1280x800/espresso_on.png
convert settings_on.png -resize 1280x800!  ../1280x800/settings_on.png
convert splash.png -resize 1280x800!  ../1280x800/splash.png
convert steam_on.png -resize 1280x800!  ../1280x800/steam_on.png
convert tea_on.png -resize 1280x800!  ../1280x800/tea_on.png
cd ..

cd 2560x1440
convert nothing_on.png -resize 1280x720!  ../1280x720/nothing_on.png
convert espresso_on.png -resize 1280x720!  ../1280x720/espresso_on.png
convert settings_on.png -resize 1280x720!  ../1280x720/settings_on.png
convert splash.png -resize 1280x720!  ../1280x720/splash.png
convert steam_on.png -resize 1280x720!  ../1280x720/steam_on.png
convert tea_on.png -resize 1280x720!  ../1280x720/tea_on.png

convert nothing_on.png -resize 1920x1080!  ../1920x1080/nothing_on.png
convert espresso_on.png -resize 1920x1080!  ../1920x1080/espresso_on.png
convert settings_on.png -resize 1920x1080!  ../1920x1080/settings_on.png
convert splash.png -resize 1920x1080!  ../1920x1080/splash.png
convert steam_on.png -resize 1920x1080!  ../1920x1080/steam_on.png
convert tea_on.png -resize 1920x1080!  ../1920x1080/tea_on.png
cd ..
