#!/bin/bash

PROGRAMS="libhtts tts"

if [ $1 = "clean" ]
then
	#rm bin/tts
	#rm bin/tts
	#rm bin/tts
	for i in $PROGRAMS; do
		cd $i
		rm -rf build
		cd ..
	done;
elif [ $1 = "debug_all" ]
then
	for i in $PROGRAMS; do
		cd $i
		mkdir build
		cd build
		cmake .. -DCMAKE_INSTALL_PREFIX=../.. -DCMAKE_BUILD_TYPE=Debug
		make && make install
		make clean
		cd ..
		cd ..
	done;
elif [ $1 = "all" ]
then
	for i in $PROGRAMS; do
		cd $i
		mkdir build
		cd build
		cmake .. -DCMAKE_INSTALL_PREFIX=../.. -DCMAKE_BUILD_TYPE=Release
		make && make install
		make clean
		cd ..
		cd ..
	done;
fi
