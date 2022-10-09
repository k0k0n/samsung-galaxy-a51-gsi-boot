#!/bin/bash

set -ex

#base=/hdd2/dumps/Samsung/SM-S908B_EUX/
#base=/hdd2/dumps/Samsung/SM-S908B
#base=/home/phh/tmp/SM-S908B_EUX/

#cp $base/recovery.img .
off=$(grep -ab -o SEANDROIDENFORCE recovery.img |tail -n 1 |cut -d : -f 1)
dd if=recovery.img of=r.img bs=4k count=$off iflag=count_bytes

off=$(grep -ab -o SEANDROIDENFORCE boot.img |tail -n 1 |cut -d : -f 1)
dd if=boot.img of=b.img bs=4k count=$off iflag=count_bytes

if [ ! -f phh.pem ];then
    openssl genrsa -f4 -out phh.pem 4096
fi

rm -Rf d
(
mkdir d
cd d
~phh/Downloads/magisk/x86/magiskboot unpack ../r.img
~phh/Downloads/magisk/x86/magiskboot cpio ramdisk.cpio extract
# Reverse fastbootd ENG mode check
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery e10313aaf40300aa6ecc009420010034 e10313aaf40300aa6ecc0094 # 20 01 00 35
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery eec3009420010034 eec3009420010035
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery 3ad3009420010034 3ad3009420010035
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery 50c0009420010034 50c0009420010035
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery 080109aae80000b4 080109aae80000b5
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery 20f0a6ef38b1681c 20f0a6ef38b9681c
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery 23f03aed38b1681c 23f03aed38b9681c
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery 20f09eef38b1681c 20f09eef38b9681c
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery 26f0ceec30b1681c 26f0ceec30b9681c
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery 24f0fcee30b1681c 24f0fcee30b9681c
~phh/Downloads/magisk/x86/magiskboot hexpatch system/bin/recovery 27f02eeb30b1681c 27f02eeb30b9681c
~phh/Downloads/magisk/x86/magiskboot cpio ramdisk.cpio 'add 0755 system/bin/recovery system/bin/recovery'
~phh/Downloads/magisk/x86/magiskboot repack ../r.img new-boot.img
cp new-boot.img ../r.img
)

/build2/AOSP-11.0/out/host/linux-x86/bin/avbtool extract_public_key --key phh.pem --output phh.pub.bin
/build2/AOSP-11.0/out/host/linux-x86/bin/avbtool add_hash_footer --partition_name recovery --partition_size $(wc -c recovery.img |cut -f 1 -d ' ') --image r.img --key phh.pem --algorithm SHA256_RSA4096
