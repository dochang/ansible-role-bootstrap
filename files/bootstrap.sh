#!/bin/sh

set -e

export LC_ALL=C

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/bin

if_not_exist() {
	! command -v "$1" >/dev/null 2>&1
}

# # apt #
#   - No need to install `python-apt` or `python3-apt`.  Ansible `apt` and
#     `apt_repository` modules will do it.
if_not_exist apt-get || {
	export DEBIAN_FRONTEND=noninteractive
	apt-get --quiet=2 --option 'Acquire::Languages=none' update
	apt-get --quiet=2 --assume-yes install python python-dev
	exit
}

if_not_exist pacman || {
	pacman --sync --quiet --noconfirm --refresh python
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

# # dnf #
#   - No need to install `python2-dnf` or `python3-dnf`.  Ansible `dnf` module
#     will do it.
if_not_exist dnf || {
	dnf --quiet makecache fast
	dnf --quiet --assumeyes install python python-devel
	exit
}

# # yum #
#   - No need to install `yum-utils`.  Ansible `yum` module will do it.
if_not_exist yum || {
	yum --quiet makecache fast
	yum --quiet --assumeyes install python python-devel
	exit
}

# # emerge #
#   - Install `gentoolkit`, which contains `equery`.  `gentoolkit` is also
#     required by Ansible `portage` module.
if_not_exist emerge || {
	emerge --quiet --sync
	emerge --quiet --ask n dev-lang/python gentoolkit
	exit
}

if_not_exist apk || {
	apk add --quiet --update-cache python python-dev
	exit
}

# Other OSes are not supported at this time.
echo 'Not supported.' 1>&2
exit 1
