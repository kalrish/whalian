#!/bin/bash

set \
	-e \
	-x \
	#
shopt \
	-s \
	-- \
	nullglob \
	#

gbp \
	buildpackage \
	--git-builder=/usr/local/bin/gbp-builder \
	--git-export-dir=/mnt \
	--git-ignore-branch \
	--git-overlay \
	--git-submodules \
	#

declare -a dscverify_options
if [[ -v DEB_SIGN_KEYID ]]
then
	gpg_homedir="$(
		gpgconf \
			--list-dirs \
			homedir \
			#
	)"

	gpg \
		--export "${DEB_SIGN_KEYID}" \
		> "${gpg_homedir}/trustedkeys.gpg" \
		#

	dscverify_options+=(
		--no-default-keyrings \
		--keyring "${gpg_homedir}/trustedkeys.gpg" \
	)
else
	dscverify_options+=(
		--no-sig-check \
	)
fi
dscverify \
	"${dscverify_options[@]}" \
	-- \
	/mnt/*.buildinfo \
	/mnt/*.changes \
	/mnt/*.dsc \
	#

cd /mnt

dpkg-source \
	--extract \
	--require-strong-checksums \
	${DEB_SIGN_KEYID:+--require-valid-signature} \
	-- \
	*.dsc \
	build \
	#

cd build

if ! dpkg-checkbuilddeps
then
	apt-get \
		update \
		#

	mk-build-deps \
		--install \
		-- \
		debian/control \
		#
fi

# --pre-clean and --post-clean not meaningful with Docker
# --root-command= because the default, `fakeroot`, isn't meaningful with Docker
dpkg-buildpackage \
	--build=binary \
	--check-builddeps \
	--no-post-clean \
	--no-pre-clean \
	--root-command= \
	#

# check before signing because signing isn't standard
# misplaced-extra-member-in-deb
# Debian bug #758054: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=758054
lintian \
	--allow-root \
	--display-experimental \
	--display-info \
	--info \
	--pedantic \
	--show-overrides \
	--verbose \
	-- \
	/mnt/*.changes \
	/mnt/*.deb \
	/mnt/*.dsc \
	#
