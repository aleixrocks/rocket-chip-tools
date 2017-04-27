#!/bin/bash


check_status() {
	MSG=$1
	if [ $? -ne 0 ]; then
		echo "ERROR: $MSG"
		exit 1
	fi
}

TIMESTAMP=`date +%s`
RHNT=rocket-$TIMESTAMP
#ROCKET_HOME_NAME=rocket-1493142031
ROCKET_HOME_NAME=$RHNT
mkdir -p $ROCKET_HOME_NAME
ROCKET_HOME=`readlink -f $ROCKET_HOME_NAME`
OS=/home/aleix/projects/ma/rc/os/kernel/builds/linux-4.6.2/vmlinux
OSBASE=/home/aleix/projects/ma/rc/os/kernel


#if false; then

echo "================ cloning repo ================="
cd $ROCKET_HOME
mkdir riscv-tools
echo "export ROCKET_HOME=$ROCKET_HOME"                > vars.sh
echo 'export RISCV=$ROCKET_HOME/riscv-tools-install' >> vars.sh
echo 'export PATH=$PATH:$RISCV/bin'                  >> vars.sh
source vars.sh
if [ -d ../rocket-base ]; then
	echo "copying existing repo..."
	cp -r ../rocket-base rocket-chip
	cd rocket-chip
	echo "updating current repo..."
	git pull
	git submodule update --init --recursive
	check_status "update"
else
	echo "clonning new repo..."
	git clone --recursive https://github.com/ucb-bar/rocket-chip.git 
	check_status "clone"
	cd rocket-chip
fi

echo "================ building riscv tools ================="
cd riscv-tools
export MAKEFLAGS="$MAKEFLAGS -j8"
./build.sh
check_status "riscv-tools install"
cd ..

echo "================ building riscv gnu toolchain ================="
cd riscv-tools/riscv-gnu-toolchain
./configure --prefix=$RISCV
make linux
check_status "riscv gnu toolchain"
cd ..


echo "================ building the kernel ================="
cd $OSBASE
./kernel-build.sh
check_status "kernel build"
cd $ROCKET_HOME/rocket-chip

#else
#	cd $ROCKET_HOME
#	source vars.sh
#	cd rocket-chip
#fi


echo "================ building bbl ================="
cd riscv-tools/riscv-pk
mkdir build.with.payload
cd build.with.payload
../configure --prefix=$RISCV/riscv64-unknown-elf.payload \
       --host=riscv64-unknown-elf \
       --with-payload=$OS \
       --disable-logo
check_status "bbl configure"
make
check_status "bbl make"
make install
check_status "bbl install"
cd $ROCKET_HOME/rocket-chip


echo "================ building emulator ================="
cd emulator
make -j8 run CONFIG=DualCoreConfig
check_status "emulator"
cd ..

