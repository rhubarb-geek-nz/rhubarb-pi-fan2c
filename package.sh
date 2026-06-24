#!/bin/sh -e
#
#  Copyright 2020, Roger Brown
#
#  This file is part of rhubarb pi.
#
#  This program is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
# 
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>
#
# $Id: package.sh 25 2021-01-19 23:12:21Z rhubarb-geek-nz $
#

svnVer()
{
	svn info . | grep "Revision:" | while read A B C
	do
		echo $B
	done
}

cleanup()
{
	make clean
	rm -rf debian-binary control.tar.* data.tar.* data control
}

getSize()
{
	du -sk data | while read A B
	do
		echo $A
	done
}

getDepends()
{
	dpkg -S libwiringPi.so | sed "y/:/ /" | while read A B
	do
		echo "$A"
		break
	done
}

cleanup

trap cleanup 0

make

VERSION=`svnVer`
VERSION="1.0.$VERSION"
PKGNAME=rhubarb-pi-fan2c
DPKGARCH=`dpkg --print-architecture`
DEPENDS=`getDepends`
VERSION="$VERSION-$DEPENDS"

mkdir data control

echo "2.0" > debian-binary

cat > control/postinst <<EOF
#!/bin/sh -e
if test ! -h /etc/systemd/system/rhubarb-pi-fan2c.service
then
	ln -s /opt/RHBpifan/etc/rhubarb-pi-fan2c.service /etc/systemd/system/rhubarb-pi-fan2c.service
fi
if test ! -h /etc/systemd/system/rhubarb-pi-fan2c.timer
then
	ln -s /opt/RHBpifan/etc/rhubarb-pi-fan2c.timer /etc/systemd/system/rhubarb-pi-fan2c.timer
fi
if test ! -h /etc/systemd/system/timers.target.wants/rhubarb-pi-fan2c.timer
then
	ln -s /opt/RHBpifan/etc/rhubarb-pi-fan2c.timer /etc/systemd/system/timers.target.wants/rhubarb-pi-fan2c.timer
fi
EOF

cat > control/postrm <<EOF
#!/bin/sh -e
rm -rf /etc/systemd/system/rhubarb-pi-fan2c.service /etc/systemd/system/timers.target.wants/rhubarb-pi-fan2c.timer /etc/systemd/system/rhubarb-pi-fan2c.timer
EOF

chmod +x control/post*

(
	set -e
	cd data
	mkdir -p opt/RHBpifan/etc opt/RHBpifan/bin
	cp ../fan2c opt/RHBpifan/bin/fan2c

	cat >  opt/RHBpifan/etc/rhubarb-pi-fan2c.service << 'EOF'
[Unit]
Description=Monitors the temperature
Wants=rhubarb-pi-fan2c.timer

[Service]
Type=oneshot
ExecStart=/opt/RHBpifan/bin/fan2c

[Install]
WantedBy=multi-user.target
EOF

	cat >  opt/RHBpifan/etc/rhubarb-pi-fan2c.timer << 'EOF'
[Unit]
Description=Monitors the temperature
Requires=rhubarb-pi-fan2c.service

[Timer]
Unit=rhubarb-pi-fan2c.service
OnCalendar=*-*-* *:*:00

[Install]
WantedBy=timers.target
EOF
	)

SIZE=`getSize`

cat > control/control <<EOF
Package: $PKGNAME
Version: $VERSION
Architecture: $DPKGARCH
Installed-Size: $SIZE
Maintainer: rhubarb-geek-nz@users.sourceforge.net
Section: electronics
Priority: extra
Depends: $DEPENDS
Vcs-Svn: https://svn.code.sf.net/p/rhubarb-pi/code/trunk/pkg/rhubarb-pi-fan2c
Description: Fan Control
 Fan Control on GPIO 14
 .
EOF

for d in data control
do
	(
		set -e
		cd $d
		tar --owner=0 --group=0 --create --xz --file - *
	) > $d.tar.xz
done

cat control/control

ar r "$PKGNAME"_"$VERSION"_"$DPKGARCH".deb debian-binary control.tar.* data.tar.*
