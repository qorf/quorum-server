#!/bin/sh

echo "Copying Web Folders"
rm -r html
cp -r ../quorum-website/QuorumWebsite/html html
cp ../quorum-language/Quorum/Library/Compiled/Run/QuorumStandardLibrary.js html/script/QuorumStandardLibrary.js
#Adding the files necessary for fonts from Plugins/GamePlugin/Native/Web to the html/script directory
cp ../quorum-language/Plugins/GamePlugin/Native/Web/load.js html/script/load.js
cp ../quorum-language/Plugins/GamePlugin/Native/Web/load.data html/script/load.data
cp ../quorum-language/Plugins/GamePlugin/Native/Web/load.wasm html/script/load.wasm

echo "Copying Quorum Compiler"
rm -r Quorum
cp -r ../quorum-language/Quorum/Run Quorum
mv Quorum/Default.jar Quorum/Quorum.jar

echo "Copying Standard Library."
cp -r ../quorum-language/Quorum/Library Quorum/Library

echo "Generate documentation"
cd Quorum/
java -jar Quorum.jar -documentLibrary
cd ..
rm -r html/Libraries/
cp Quorum/Run/Documents/libraries.html html/libraries.html
cp -r Quorum/Run/Documents/Libraries html/Libraries

echo "Setup Completed."
