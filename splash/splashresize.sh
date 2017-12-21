#!/bin/bash

cd /d/admin/code/de1beta/splash
#dirs=( "1280x800" "1920x1200" "1920x1080" "1280x720" "2560x1440" "2048x1440" "2048x1536" )
convert 2560x1600/de1.jpg -quality 90 -resize 1280x800 1280x800/de1.jpg 
exit

dirs=( "1280x800"  )
echo "Resizing splash JPGs"

for i in "${dirs[@]}"
do
   	rm ../$i/*.jpg
   	mkdir -p ../$i/
   	echo $i
	find . -name "*.jpg" -print0 -exec convert {} -quality 50 -resize $i! ../$i/{} \; &
done

wait
echo
echo "done"
exit


rm ../1280x800/*.jpg
rm ../1920x1200/*.jpg
rm ../1920x1080/*.jpg
rm ../1280x720/*.jpg
rm ../2560x1440/*.jpg
rm ../2048x1440/*.jpg

echo "Resizing splash JPGs for 1280x800"
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 1280x800 ../1280x800/{} \; 
echo 

echo "Resizing splash JPGs for 1920x1200"
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 1920x1200 ../1920x1200/{} \; 
echo 

echo "Resizing splash JPGs for 1920x1080"
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 1920x1080 ../1920x1080/{} \; 
echo 

echo "Resizing splash JPGs for 1280x720"
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 1280x720 ../1280x720/{} \; 
echo 

echo "Resizing splash JPGs for 2048x1440"
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 2048x1440 ../2048x1440/{} \; 
echo 

echo "Resizing splash JPGs for 2560x1440"
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 2560x1440 ../2560x1440/{} \; 
echo 

echo done
