#!/bin/sh

distro="$1"
release="$2"

export \
	DOCKER_BUILDKIT=1 \
	#

exec \
	docker \
	build \
	--tag "whalian:${distro}-${release}" \
	-- \
	"${distro}/${release}" \
	#
