#!/bin/bash


cd /d/admin/code/de1beta/saver/2560x1600
dirs=( "1280x800" "1920x1200" "1920x1080" "1280x720"  "2560x1440" "2048x1440" "2048x1536" )

echo "Resizing screen saver JPGs"

for i in "${dirs[@]}"
do
   	rm ../$i/*.jpg
   	mkdir -p ../$i/
	find . -name "*.jpg" -print0 -exec convert {} -quality 50 -resize $i! ../$i/{} \; &
	#echo 
done

wait
echo
echo "done"
exit



cd /d/admin/code/de1beta/saver/2560x1600
rm ../1280x800/*.jpg
rm ../1920x1200/*.jpg
rm ../1280x720/*.jpg
rm ../1920x1080/*.jpg
rm ../2560x1440/*.jpg

echo "Resizing saver JPGs for 1280x800"
echo ---
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 1280x800 ../1280x800/{} \; 
echo 

echo 
echo "Resizing saver JPGs for 1920x1200"
echo ---
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 1920x1200 ../1920x1200/{} \; 
echo 

echo 
echo "Resizing saver JPGs for 2560x1440"
echo ---
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 2560x1440 ../2560x1440/{} \; 
echo 

echo 
echo "Resizing saver JPGs for 1920x1080"
echo ---
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 1920x1080 ../1920x1080/{} \; 
echo 

echo 
echo "Resizing saver JPGs for 1280x720"
echo ---
find . -name "*.jpg" -print0 -exec convert {} -quality 75 -resize 1280x720 ../1280x720/{} \; 
echo 

echo done
