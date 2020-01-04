#!/bin/bash

echo converting tifs
convert -strip ~/Desktop/settings_pages_all0000.tif settings_1.png &
convert -strip ~/Desktop/settings_pages_all0001.tif settings_2.png &
convert -strip ~/Desktop/settings_pages_all0002.tif settings_2a.png &
convert -strip ~/Desktop/settings_pages_all0003.tif settings_2a2.png &
convert -strip ~/Desktop/settings_pages_all0004.tif settings_2b.png &
convert -strip ~/Desktop/settings_pages_all0005.tif settings_2b2.png &
convert -strip ~/Desktop/settings_pages_all0006.tif settings_2c.png &
convert -strip ~/Desktop/settings_pages_all0007.tif settings_2c2.png &
convert -strip ~/Desktop/settings_pages_all0008.tif settings_3.png &
convert -strip ~/Desktop/settings_pages_all0009.tif settings_4.png &
convert -strip ~/Desktop/settings_pages_all0010.tif settings_message.png &
convert -strip ~/Desktop/settings_pages_all0011.tif settings_3_choices.png &
wait

rm  ~/Desktop/settings_pages_all0000.tif 
rm  ~/Desktop/settings_pages_all0001.tif 
rm  ~/Desktop/settings_pages_all0002.tif 
rm  ~/Desktop/settings_pages_all0003.tif 
rm  ~/Desktop/settings_pages_all0004.tif 
rm  ~/Desktop/settings_pages_all0005.tif 
rm  ~/Desktop/settings_pages_all0006.tif 
rm  ~/Desktop/settings_pages_all0007.tif 
rm  ~/Desktop/settings_pages_all0008.tif 
rm  ~/Desktop/settings_pages_all0009.tif 
rm  ~/Desktop/settings_pages_all0010.tif 
rm  ~/Desktop/settings_pages_all0011.tif 

echo optimizing PNGs

zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_1.png settings_1.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_2.png settings_2.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_2a.png settings_2a.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_2a2.png settings_2a2.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_2b.png settings_2b.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_2b2.png settings_2b2.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_2c.png settings_2c.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_2c2.png settings_2c2.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_3.png settings_3.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_4.png settings_4.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_message.png settings_message.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y settings_3_choices.png settings_3_choices.png &

wait

cd ../../..
./skinresize.tcl
