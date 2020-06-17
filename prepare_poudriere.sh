#!/bin/sh

PORTSDIR=/usr/ports

set -ex

pwd

cd /usr
mv ports ports.old

git clone --depth=1 --single-branch -b master https://github.com/freebsd/freebsd-ports.git ports

mkdir ${PORTSDIR}/distfiles

df -h

echo "NO_ZFS=yes" >> /usr/local/etc/poudriere.conf
echo "ALLOW_MAKE_JOBS=yes" >> /usr/local/etc/poudriere.conf
sed -i.bak -e 's,FREEBSD_HOST=_PROTO_://_CHANGE_THIS_,FREEBSD_HOST=https://download.FreeBSD.org,' /usr/local/etc/poudriere.conf
mkdir -p /usr/local/poudriere

poudriere jail -c -j jail -v `uname -r`
poudriere ports -c -f none -m null -M ${PORTSDIR}

# use an easy port to bootstrap pkg repo
poudriere bulk -t -j jail net/nc

mkdir /tmp/pkgs
