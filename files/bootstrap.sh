#!/bin/sh

set -e

export LC_ALL=C

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/bin

PIP_INSTALLER_URI=https://bootstrap.pypa.io/get-pip.py

if_not_exist() {
	! command -v "$1" >/dev/null 2>&1
}

download() {
	curl --silent --show-error --location "$@"
}

install_pip() {
	if_not_exist pip2 || {
		# Install pip from upstream instead of distro since these bugs:
		#
		# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=744145
		# https://bugs.launchpad.net/ubuntu/+source/python-pip/+bug/1306991
		# https://github.com/docker/docker-py/issues/525#issuecomment-79428103
		download ${PIP_INSTALLER_URI} | python2
	}
	pip2 install --upgrade pip
}

if_not_exist apt-get || {
	export DEBIAN_FRONTEND=noninteractive
	apt-get --quiet=2 update
	apt-get --quiet=2 --assume-yes install python python-dev lsb-release curl
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
	zypper --quiet --non-interactive install --auto-agree-with-licenses python python-devel lsb-release python-xml curl
	install_pip
	exit
}

if_not_exist dnf || {
	dnf --quiet makecache fast
	dnf --quiet --assumeyes install python python-devel redhat-lsb-core curl
	install_pip
	exit
}

if_not_exist yum || {
	yum --quiet makecache fast
	yum --quiet --assumeyes install python python-devel redhat-lsb-core curl
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
