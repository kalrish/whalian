#!/bin/bash

set \
	-e \
	-x \
	#

export \
	DEBIAN_FRONTEND=noninteractive \
	#

apt-get \
	--yes \
	update \
	#

# --no-install-recommends helps spot forgotten dependencies in debian/control
# devscripts provides:
#   - debsign(1)
#   - dscverify(1)
#   - mk-build-deps(1)
# dpkg-dev provides:
#   - dpkg-buildpackage(1)
#   - dpkg-checkbuilddeps(1)
#   - dpkg-source(1)
# equivs is required by:
#   - mk-build-deps(1)
apt-get \
	--yes \
	install \
	--no-install-recommends \
	bash \
	build-essential \
	debsigs \
	debsig-verify \
	devscripts \
	dpkg-dev \
	dpkg-sig \
	equivs \
	git-buildpackage \
	gnupg \
	lintian \
	#

apt-get \
	--yes \
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
