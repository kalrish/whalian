#!/bin/sh

exec \
	dpkg-buildpackage \
	--compression-level=best \
	--build=source \
	--no-check-builddeps \
	--no-pre-clean \
	--root-command= \
	#
