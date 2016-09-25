#!/bin/bash
#Author: Michail Vourlakos
#Summary: Installation script for Now Dock Plasmoid
#This script was written and tested on openSuSe Leap 42.1

if [ -d build ]; then
    cd build
    rm -fr *
else
    mkdir build
    cd build
fi

cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
sudo make install
