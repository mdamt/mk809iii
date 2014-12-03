set -e
DISTRO=tambora
DEBREPO=http://arsip-dev.blankonlinux.or.id/blankon

if [ ! -d devrootfs ];then
sudo qemu-debootstrap --no-check-gpg --arch armhf $DISTRO devrootfs $DEBREPO /usr/share/debootstrap/scripts/sid
fi
echo "deb $DEBREPO $DISTRO main" > sources.list
sudo mv sources.list devrootfs/etc/apt
sudo chroot devrootfs apt update 
sudo chroot devrootfs apt install fbset busybox-static
mkdir -p ramdisk/lib/arm-linux-gnueabihf/
mkdir -p ramdisk/bin
cp devrootfs/lib/ld-linux-armhf.so.3 ramdisk/lib/
cp devrootfs/lib/arm-linux-gnueabihf/libc.so.6 ramdisk/lib/arm-linux-gnueabihf/
cp devrootfs/bin/busybox ramdisk/bin
cp devrootfs/bin/fbset ramdisk/bin

cd ramdisk
find . -print |cpio -H newc -o |gzip -9 > ../ramdisk.cpio.gz
cd ..

if [ ! -d rkflashtool ];then
git clone https://github.com/neo-technologies/rkflashtool.git
cd rkflashtool
make
cd ..
fi

if [ ! -d rockchip-mkbootimg ];then
git clone https://github.com/neo-technologies/rockchip-mkbootimg.git
cd rockchip-mkbootimg
make
cd ..
fi

if [ ! -f kernel.img ]; then
./rkflashtool/rkcrc -k kernel kernel.img
fi
./rockchip-mkbootimg/mkbootimg --kernel kernel.img --ramdisk ramdisk.cpio.gz -o full.img 
