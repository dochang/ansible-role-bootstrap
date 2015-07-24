#!/bin/sh

set -e

export LC_ALL=C

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/bin

if_not_exist() {
	! command -v "$1" >/dev/null 2>&1
}

install_pip() {
	curl -sSL https://bootstrap.pypa.io/get-pip.py | python2
	pip2 install -U pip
}

if_not_exist apt-get || {
	export DEBIAN_FRONTEND=noninteractive
	apt-get --quiet=2 update
	apt-get --quiet=2 --assume-yes install python2.7 lsb-release curl
	install_pip
	exit
}

if_not_exist pacman || {
	pacman --sync --quiet --noconfirm --refresh python2 lsb-release curl
	install_pip
	exit
}

# # zypper #
#   - zypper must be checked before yum since zypper uses yum as backend.
#   - Install `python-xml`, because the Ansible module `zypper_repository`
#     depends on it.
if_not_exist zypper || {
	zypper --quiet refresh
	zypper --quiet --non-interactive install --auto-agree-with-licenses python lsb-release python-xml curl
	install_pip
	exit
}

if_not_exist yum || {
	yum --quiet makecache fast
	yum --quiet --assumeyes install python redhat-lsb-core curl
	install_pip
	exit
}

# # emerge #
#   - Install `gentoolkit`, which contains `equery`.
if_not_exist emerge || {
	emerge --quiet --sync
	emerge --quiet --ask n =dev-lang/python-2\* lsb-release gentoolkit net-misc/curl
	install_pip
	exit
}

# Other OSes are not supported at this time.
echo 'Not supported.' 1>&2
exit 1
