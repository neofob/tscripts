#!/bin/sh
# reference:
# https://wiki.archlinux.org/index.php/dm-crypt
# https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption

if [ "${DEBUG:-0}" = "1" ]; then
  set -x
fi

CONTAINER=${CONTAINER:=container}
# Available ciphers at /proc/crypto
# aes-xts-plain64, aes-cbc-essiv...
CIPHER=${CIPHER:-"aes-xts-essiv:sha256"}
KEY_SIZE=${KEY_SIZE:-512}
CRYPT_TYPE=${CRYPT_TYPE:-plain}
HASH=${HASH:-"ripemd160"}
# encrypted device = $1

cryptsetup --cipher ${CIPHER} \
     --key-size ${KEY_SIZE} \
     --type ${CRYPT_TYPE} \
     --hash ${HASH} \
     open $1 $CONTAINER

echo "Decrypted device available at /dev/mapper/${CONTAINER}"
