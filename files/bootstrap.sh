#!/bin/sh

set -e

export LC_ALL=C

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/bin

if_not_exist() {
	! command -v "$1" >/dev/null 2>&1
}

if_not_exist apt-get || {
	export DEBIAN_FRONTEND=noninteractive
	apt-get --quiet=2 update
	apt-get --quiet=2 --assume-yes install python python-dev
	exit
}

if_not_exist pacman || {
	pacman --sync --quiet --noconfirm --refresh python2
	exit
}

# # zypper #
#   - zypper must be checked before yum since zypper uses yum as backend.
#   - Install `python-xml`, because the Ansible module `zypper_repository`
#     depends on it.
if_not_exist zypper || {
	zypper --quiet refresh
	zypper --quiet --non-interactive install --auto-agree-with-licenses python python-devel python-xml
	exit
}

if_not_exist dnf || {
	dnf --quiet makecache fast
	dnf --quiet --assumeyes install python python-devel
	exit
}

if_not_exist yum || {
	yum --quiet makecache fast
	yum --quiet --assumeyes install python python-devel
	exit
}

# # emerge #
#   - Install `gentoolkit`, which contains `equery`.
if_not_exist emerge || {
	emerge --quiet --sync
	emerge --quiet --ask n =dev-lang/python-2\* gentoolkit
	exit
}

# Other OSes are not supported at this time.
echo 'Not supported.' 1>&2
exit 1
