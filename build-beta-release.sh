#!/bin/bash

version=`grep -o "[1-9]*\.[0-9\.]*" de1plus/version.tcl`

echo "Releasing $version"

if [ -e release/$version ] ; then
	echo "Removing old release of identical version"
    rm -r release/$version
fi


mkdir -p release/$version/source

echo "Copying support files"

cp -R misc/desktop_app/* release/$version/
cp -R de1plus/* release/$version/source

echo "Arranging source"
ln -vs `pwd`/release/$version/source release/$version/osx/src
ln -vs `pwd`/release/$version/source release/$version/win32/src
ln -vs `pwd`/release/$version/source release/$version/linux/src

chmod +x release/$version/linux/undroidwish/undroidwish-*

echo "Packing zips. This might take a while"
zip -rq "release/$version/decent_osx.zip" release/$version/osx/*
zip -rq "release/$version/decent_win.zip" release/$version/win32/*
zip -rq "release/$version/decent_linux.zip" release/$version/linux/*
zip -rq "release/$version/decent_source.zip" release/$version/source/*

echo "build created, please push the tag by running"
echo "git tag $version"
echo "git push origin --tags"
