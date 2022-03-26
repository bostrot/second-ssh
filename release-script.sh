#!/bin/bash
# get version from pubspec
version=$(cat pubspec.yaml | grep -o -P '(?<=version: ).*(?= #)')

# copy files
cp ./windows-dlls/* ./build/windows/runner/Release
cd ./build/windows/runner/Release
zip -r second-ssh-v$version.zip .

# check tag already exists
if [ "$(echo $(gh release view --json tagName) | sed -e 's/{"tagName":"\(.*\)"}/\1/')" != "v$version" ]; 
then 
gh release create v$version second-ssh-v$version.zip --notes "This is an automated release." 
fi
