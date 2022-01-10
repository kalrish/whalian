#!/bin/sh

exec \
	dpkg-source \
	--build \
	--compression-level=best \
	-- \
	. \
	#
