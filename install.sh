#!/bin/bash

echo "add to your ~/.bashrc file :"
echo export PATH=$PWD/bin:\$PATH

git config --file=$HOME/.gtools.ini --replace-all GTools.path $PWD

