
!/bin/sh

#1.3 Development Tools Setup
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
apt-get -qq --yes u-boot-tools

#1.3.2 Workspace Setup
echo "Building directories"
cd $HOME
mkdir -p development/rtems
cd $HOME/development/rtems
mkdir build-rtems-zedboard
mkdir compiler

#fix HOME directory permissions
chown -R $USER: $HOME


#2.1 U-Boot Tools
cd $HOME
mkdir -p development/u-boot

echo "Copying dtc and u-boot-xlnx"
cp /media/nadeem/FC94-2B94/dtc.zip ~/development/u-boot
cp /media/nadeem/FC94-2B94/u-boot-xlnx.zip ~/development/u-boot
cd $HOME/development/u-boot
unzip -qq dtc.zip
unzip -qq u-boot-xlnx
rm dtc.zip
rm u-boot-xlnx.zip

#fix u-boot directory permissions
chown -R $USER: $HOME/development/u-boot

#2.2 Device Tree Compiler
cd $HOME/development/u-boot/dtc
make 
make install

#2.2.1 Add DTC to PATH
cd $HOME
PATH = "$HOME/bin:$HOME/.local/bin:$PATH"
END
 chown -R $USER: $HOME
 chown -R $USER: $HOME/development/u-boot
#2.4 U-Boot Build
cd $HOME/development/u-boot/u-boot-xlnx
make zynq_zed_defconfig
chown -R $USER: $HOME
make CROSS_COMPILE=arm-none-eabi- CONFIG_API=y

