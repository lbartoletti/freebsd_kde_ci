#!/bin/sh
PORTSDIR=/usr/ports

# get new version from portscout
curl -s https://portscout.freebsd.org/kde@freebsd.org.html > /tmp/kde_to_update.html

cd ${PORTSDIR}

## get SIP version from portscout
SIP_NEW_VERSION=`grep py-sip /tmp/kde_to_update.html | awk -F "</*td>|</*tr>" '/<\/*t[rd]>.*[A-Z][A-Z]/ {print $8 }' | awk -F'>|</a>' '{print $2}'`
# bump SIP version
sed -i '' -e "/SIP_VERSION=/s/=.*$/=\t\t${SIP_NEW_VERSION}/" Mk/Uses/pyqt.mk

# ports using PYQT
grep -r --include \*Makefile 'USE_PYQT' . | awk -F '/' '{print $2 "/" $3}' | uniq > /tmp/use_pyqt

# Use sip
cat /tmp/use_pyqt | xargs grep --include \*Makefile -r sip > /tmp/sip ;  awk -F '/' '{print $1 "/" $2}' /tmp/sip | uniq | grep -v py-sip > /tmp/use_sip


# get QSCI version from portscout
QSCI_NEW_VERSION=`grep qscintilla2-qt5 /tmp/kde_to_update.html | awk -F "</*td>|</*tr>" '/<\/*t[rd]>.*[A-Z][A-Z]/ {print $8 }' | awk -F'>|</a>' '{print $2}'`
# bump QSCI version
sed -i '' -e "/QSCI2_VERSION=/s/=.*$/=\t\t${QSCI_NEW_VERSION}/" Mk/Uses/pyqt.mk

# ports using qscintilla2
grep -r --include \*Makefile 'qscintilla2' . | awk -F '/|:' '{print $2 "/" $3}' | sort | uniq | grep -v "qscintilla" > /tmp/use_qscintilla2

cat /tmp/use_qscintilla2 /tmp/use_sip | sort | uniq > /tmp/to_build
cat /tmp/to_build | xargs Tools/scripts/bump-revision.sh
