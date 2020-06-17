#!/bin/sh

PORTSDIR=/usr/ports

cd ${PORTSDIR}
for p in `cat /tmp/to_build`
    sudo pkg fetch -y -o /tmp/pkgs `make missing-packages`
done

rm -fr /usr/local/poudriere/data/packages/jail-default/.latest/All
mv pkgs/All /usr/local/poudriere/data/packages/jail-default/.latest/
rm -fr pkgs

set +e
poudriere testport -j jail ${PORT}
RESULT=$?
set -e

ls -1 /usr/local/poudriere/data/logs/bulk/jail-default/latest/logs/errors
for i in /usr/local/poudriere/data/logs/bulk/jail-default/latest/logs/errors/*.log
do
	echo ==== $i ====
	cat $i
done

exit ${RESULT}
