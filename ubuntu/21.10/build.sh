#!/bin/bash

set \
	-e \
	-x \
	#

if [[ -v key_id ]]
then
	export \
		-- \
		DEB_SIGN_KEYID="${key_id}" \
		DEBSIGN_KEYID="${key_id}" \
		#

	gpg_homedir="$(
		gpgconf \
			--list-dirs \
			homedir \
			#
	)"

	gpg \
		--export "${key_id}" \
		> "${gpg_homedir}/trustedkeys.gpg" \
		#

	# debsig-verify uses long key IDs
	long_key_id="${key_id: -16}"

	debsig_policy_directory="/etc/debsig/policies/${long_key_id}"
	debsig_keyrings_directory="/usr/share/debsig/keyrings/${long_key_id}"

	mkdir \
		--parents \
		-- \
		"${debsig_policy_directory}" \
		"${debsig_keyrings_directory}" \
		#

	sed \
		-e "s/KEY_ID/${long_key_id}/g" \
		-- \
		/usr/local/share/debsig-policy.xml \
		> "${debsig_policy_directory}/.pol" \
		#

	gpg \
		--export "${key_id}" \
		> "${debsig_keyrings_directory}/trustedkeys.gpg" \
		#
fi

gbp \
	buildpackage \
	--git-builder=/usr/local/bin/gbp-builder \
	--git-export-dir=/mnt \
	--git-ignore-branch \
	--git-ignore-new \
	--git-submodules \
	#

if [[ -v key_id ]]
then
	# The key ID must be passed as a command argument
	# because devscripts do not honor environment variables
	debsign \
		-k "${DEBSIGN_KEYID}" \
		-S \
		-- \
		/mnt/*.dsc \
		#
fi

lintian \
	--allow-root \
	--display-experimental \
	--display-info \
	--info \
	--pedantic \
	--show-overrides \
	--verbose \
	-- \
	/mnt/*.dsc \
	#

# FIXME: DRY
if [[ -v key_id ]]
then
	dscverify \
		--no-default-keyrings \
		--keyring "${gpg_homedir}/trustedkeys.gpg" \
		-- \
		/mnt/*.dsc \
		#
else
	dscverify \
		--no-sig-check \
		-- \
		/mnt/*.dsc \
		#
fi

cd /mnt

dpkg-source \
	--extract \
	--require-strong-checksums \
	${key_id:+--require-valid-signature} \
	-- \
	*.dsc \
	build \
	#

cd build

if ! dpkg-checkbuilddeps
then
	# In Ubuntu 21.10, --tool defaults to
	# apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends
	mk-build-deps \
		--install \
		-- \
		debian/control \
		#
fi

# --post-clean not meaningful with Docker
# --no-sign because dpkg-buildpackage signs only source packages
# --root-command= because the default, `fakeroot`, isn't meaningful with Docker
dpkg-buildpackage \
	--build=binary \
	--check-builddeps \
	--no-post-clean \
	--no-sign \
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
	../*.deb \
	#

if [[ -v key_id ]]
then
	# $DEBSIGN_KEYID = -k
	dpkg-sig \
		--sign=builder \
		--verbose \
		-- \
		../*.deb \
		#

	# The key ID must be passed as a command argument
	# because debsigs doesn't honor environment variables
	debsigs \
		--default-key "${DEB_SIGN_KEYID}" \
		--sign=origin \
		-- \
		../*.deb \
		#

	#dpkg-sig \
	#	--verbose \
	#	--verify \
	#	-- \
	#	../*.deb \
	#	#

	# doesn't support `--` to separate options from parameters
	debsig-verify \
		--debug \
		../*.deb \
		#
fi
