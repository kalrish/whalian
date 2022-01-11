#!/bin/sh

distro="$1"
release="$2"

export \
	DOCKER_BUILDKIT=1 \
	#

exec \
	docker \
	build \
	--label org.opencontainers.image.source=https://github.com/kalrish/whalian \
	--tag "ghcr.io/kalrish/whalian:${distro}-${release}" \
	-- \
	"${distro}/${release}" \
	#
