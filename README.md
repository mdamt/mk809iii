Running Linux on MK809III
=========================

We will use BlankOn Linux in this tutorial.

Preparation
===========
Create a working directory, called `mk809iii`
```
mkdir mk809iii
cd mk809iii
export WORK=`pwd`
```


Kernel
======

Get the kernel from https://github.com/mdamt/linux in branch mk809iii.
```
git clone --depth 1 https://github.com/mdamt/linux -b mk809iii
```

Get the toolchain to compile:
```
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6
```

Now you will have two directories: `linux` and `arm-eabi-4.6` on the same level
Prepare the compilation and build
```
cd linux
cp blankon/config .config
source blankon/envsetup.sh
make -z9 zImage
```

Adjust `9` to the number of cores of your processor.

The result is `arch/arm/boot/zImage` file.

ramdisk
=======

Get the base ramdisk:
```
cd $WORK
git clone https://github.com/mdamt/mk809iii

```

Copy the kernel file as `kernel`:
```
cd $WORK/mk809iii
cp ../linux/arch/arm/boot/zImage kernel
```

Build the ramdisk image:
```
sudo ./build-ramdisk.sh
```

The result is `full.img` file.

Install to SD CARD
==================

Get the bootloader: `http://files.androtab.info/radxa/sdboot_rk3188_miniroot.zip`

Extract and install `full.img` from previous step to SD CARD.
```
dd if=sdboot_rk3188.img of=/dev/XXX conv=sync,fsync
dd if=parameter_fbcon.img of=/dev/XXX conv=sync,fsync seek=$((0x2000))
dd if=full.img of=/dev/XXX conv=sync,fsync seek=$((0x2000+0x4000))
```

Adjust `/dev/XXX` to your SD card device assignment.
