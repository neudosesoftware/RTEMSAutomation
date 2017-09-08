
#!/bin/sh
#:<<'END'
#1.3 Development Tools Setup
echo "1.3.1 Development Tools Setup"
echo "Updating Existing Packages"
apt-get --yes update
apt-get --yes upgrade
apt-get --yes dist-upgrade

echo "Installing Development Tools"
apt-get -qq --yes install build-essential
apt-get -qq --yes install git
apt-get -qq --yes install python 2.7-dev
apt-get -qq --yes install libssl-dev
apt-get -qq --yes install vim 
apt-get -qq --yes install binutils-arm-none-eabi
apt-get -qq --yes install gcc-arm-none-eabi
apt-get -qq --yes build-dep binutils gcc g++ gdb unzip
apt-get -qq --yes install u-boot-tools

#1.3.2 Workspace Setup
echo "1.3.2 Workspace Setup"
echo "Building directories"
cd $HOME
mkdir -p development/rtems
cd $HOME/development/rtems
mkdir build-rtems-zedboard
mkdir compiler

#fix HOME directory permissions
chown -R $USER: $HOME

#replace this with local directories later
cd $HOME/development/rtems
git clone git://git.rtems.org/rtems-source-builder.git
git clone git://git.rtems.org/rtems.git rtems-git
chown -R $USER: $HOME

#2.1 U-Boot Tools
echo "2.1 U-Boot Tools"
cd $HOME
mkdir -p development/u-boot

echo "Copying dtc and u-boot-xlnx"
cp ~HOME/dtc.zip ~/development/u-boot
cp ~HOME/u-boot-xlnx.zip ~/development/u-boot
cd $HOME/development/u-boot
unzip -qq dtc.zip
unzip -qq u-boot-xlnx
rm dtc.zip
rm u-boot-xlnx.zip

#fix u-boot directory permissions
chown -R $USER: $HOME/development/u-boot

#2.2 Device Tree Compiler
echo "2.2 Device Tree Compiler"
cd $HOME/development/u-boot/dtc
make 
chown -R $USER: $HOME/development/u-boot
make install
#END
#BEGINNING OF C2~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#2.2.1 Add DTC to PATH
echo "2.2.1 Add DTC to PATH"
cd $HOME
#sed -i '$ d' ~/.profile
#sed -i '$ d' ~/.profile
#echo "PATH=\"$HOME/bin:$HOME/development/u-boot/dtc:$PATH#\"">>~/.profile
#echo "fi">>~/.profile
export PATH="$HOME/development/u-boot/dtc:$PATH"
chown -R $USER: $HOME/development/u-boot

#2.4 U-Boot Build
echo "2.4 U-Boot Build"
cd $HOME/development/u-boot/u-boot-xlnx
make zynq_zed_defconfig
chown -R $USER: $HOME
make CROSS_COMPILE=arm-none-eabi- CONFIG_API=y

#3.1.1 Check RSB Environment
echo "3.1.1 Check RSB Environment"
cd $HOME/development/rtems/rtems-source-builder/rtems
../source-builder/sb-check

#3.1.2 Build RSB Tools for RTEMS 4.12
echo "3.1.2 Build RSB Tools for RTEMS 4.12"
echo "This is the longest step"
cd $HOME/development/rtems/rtems-source-builder/rtems
../source-builder/sb-set-builder --log=rtems-arm-build-log.txt --prefix=$HOME/development/rtems/compiler/4.12 4.12/rtems-arm

#BEGINNING OF C3~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
apt-get -qq --yes install u-boot-tools
#3.1.3 Add Compiler to Path
echo "3.1.3 Add Compiler to PATH"
#cd $HOME
#sed -i '$ d' ~/.profile
#sed -i '$ d' ~/.profile
#echo "PATH=\"$HOME/bin:$HOME/development/u-boot/dtc:$HOME/development/rtems/compiler/4.12/bin:$PATH\"">>~/.profile
#echo "fi">>~/.profile
export PATH="$HOME/development/rtems/compiler/4.12/bin:$PATH"

#3.2.1 RTEMS 4.12 Patch
echo "3.2.1 RTEMS 4.12 Patch"
cd $HOME/development/rtems/rtems-git/c/src/lib/libbsp/arm/shared/include
rm arm-cp15-start.h
cp $HOME/arm-cp15-start.h ~/development/rtems/rtems-git/c/src/lib/libbsp/arm/shared/include

cd $HOME/development/rtems/rtems-git/c/src/lib/libbsp/arm/xilinx-zynq/startup
rm bspstartmmu.c
cp $HOME/bspstartmmu.c ~/development/rtems/rtems-git/c/src/lib/libbsp/arm/xilinx-zynq/startup
chown -R $USER: $HOME


#3.2.2 Bootstrap
echo "3.2.2 Bootstrap"
cd $HOME/development/rtems/rtems-git
./bootstrap -c
./bootstrap -p
$HOME/development/rtems/rtems-source-builder/source-builder/sb-bootstrap

#3.2.3 Configure RTEMS for Build
echo "3.2.3 Configure RTEMS for Build"
cd $HOME/development/rtems/build-rtems-zedboard
../rtems-git/configure --target=arm-rtems4.12 --prefix=/opt/work/chris/rtems/kernel/4.12 --disable-networking --enable-rtemsbsp=xilinx_zynq_zedboard --enable-smp --enable-test


###~~~~~SPLIT THE SCRIPT HERE~~~~~###
#This section is for testing/ building applications only
#3.2.4 Build RTEMS
echo "3.2.4 Build RTEMS"
chown -R $USER: $HOME
cd $HOME/development/rtems/build-rtems-zedboard
make all
chown -R $USER: $HOME
#3.2.5 Convert RTEMS Executable to IMG Format
echo "3.2.5 Convert RTEMS Executable to IMG Format"
cd $HOME/development/rtems/build-rtems-zedboard/arm-rtems4.12/c
cd xilinx_zynq_zedboard/testsuites/samples/ticker
OBJCOPY="$HOME/development/rtems/compiler/4.12/bin/arm-rtems4.12-objcopy"
START_ADDR=0x00104000
ENTRY_ADDR=0x00104000
${OBJCOPY} -R -S --strip-debug -O binary "ticker.exe" "ticker.bin"
cat "ticker.bin" | gzip -9 >"ticker.gz"
mkimage -A arm -O rtems -T kernel -a $START_ADDR -e $ENTRY_ADDR -n "RTEMS" -d "ticker.gz" "ticker.img"

