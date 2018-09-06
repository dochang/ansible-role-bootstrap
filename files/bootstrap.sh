#!/bin/sh

set -e

export LC_ALL=C

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/bin

if_not_exist() {
	! command -v "$1" >/dev/null 2>&1
}

sed_in_place() {
	script_file="$1"
	target_file="$2"
	work_file=$(mktemp)

	sed -E -f "$script_file" "$target_file" > "$work_file"
	cp -f "$work_file" "$target_file"
	chmod 644 "$target_file"
	rm -f "$work_file"
}

# # apt #
#   - No need to install `python-apt` or `python3-apt`.  Ansible `apt` and
#     `apt_repository` modules will do it.
if_not_exist apt-get || {
	export DEBIAN_FRONTEND=noninteractive
	export APT_LISTCHANGES_FRONTED=none
	export APT_LISTBUGS_FRONTEND=none
	if dpkg --compare-versions "$(dpkg-query --show --showformat='${Version}\n' apt)" lt 1.5; then
		apt-get --quiet=2 update
		apt-get --quiet=2 --assume-yes install apt-transport-https
	fi

	sed_file=$(mktemp)
	: > "$sed_file"
	. /etc/os-release
	case ${ID} in
	debian)
		: ${BOOTSTRAP_DEBIAN_URI:=https://deb.debian.org/debian}
		: ${BOOTSTRAP_DEBIAN_SECURITY_URI:=https://deb.debian.org/debian-security}
		echo "s|https?://deb\.debian\.org/debian|${BOOTSTRAP_DEBIAN_URI}|" >> "$sed_file"
		echo "s|https?://http(\.[a-z][a-z])?\.debian\.org/debian|${BOOTSTRAP_DEBIAN_URI}|" >> "$sed_file"
		echo "s|https?://security\.debian\.org/debian-security|${BOOTSTRAP_DEBIAN_SECURITY_URI}|" >> "$sed_file"
		sed_in_place "$sed_file" /etc/apt/sources.list
		# Some VPS providers (e.g. DigitalOcean) use
		# "http://security.debian.org" for security source.
		: > "$sed_file"
		echo "s|https?://security\.debian\.org|${BOOTSTRAP_DEBIAN_SECURITY_URI}|" >> "$sed_file"
		sed_in_place "$sed_file" /etc/apt/sources.list
		;;
	raspbian)
		: ${BOOTSTRAP_RASPBIAN_URI:=http://raspbian.raspberrypi.org/raspbian}
		: ${BOOTSTRAP_RASPBIAN_RASPI_URI:=http://deb.debian.org/debian-security}
		echo "s|https?://archive\.raspbian\.org/raspbian/|${BOOTSTRAP_RASPBIAN_URI}|" >> "$sed_file"
		echo "s|https?://mirrordirector\.raspbian\.org/raspbian/|${BOOTSTRAP_RASPBIAN_URI}|" >> "$sed_file"
		sed_in_place "$sed_file" /etc/apt/sources.list
		: > "$sed_file"
		echo "s|https?://archive.raspberrypi.org/debian/|${BOOTSTRAP_RASPBIAN_RASPI_URI}|" >> "$sed_file"
		sed_in_place "$sed_file" /etc/apt/sources.list.d/raspi.list
		;;
	esac
	rm -f "$sed_file"
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
