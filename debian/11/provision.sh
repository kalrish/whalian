#!/bin/sh

set \
	-e \
	-x \
	#

apt-get \
	update \
	#

# --no-install-recommends helps spot forgotten dependencies in debian/control
# devscripts provides:
#   - dscverify(1)
#   - mk-build-deps(1)
# dpkg-dev provides:
#   - dpkg-buildpackage(1)
#   - dpkg-checkbuilddeps(1)
#   - dpkg-source(1)
# equivs is required by:
#   - mk-build-deps(1)
apt-get \
	install \
	--no-install-recommends \
	bash \
	build-essential \
	devscripts \
	dpkg-dev \
	equivs \
	git-buildpackage \
	gnupg \
	lintian \
	#

apt-get \
	clean \
	#

gpg_homedir="$(
	gpgconf \
		--list-dirs \
		homedir \
		#
)"

mkdir \
	--mode u=rwx,go= \
	-- \
	"${gpg_homedir}" \
	#

rm \
	-- \
	/usr/local/bin/provision \
	#
