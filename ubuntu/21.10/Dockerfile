FROM ubuntu:21.10

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src

COPY \
	apt.conf \
	/etc/apt/apt.conf.d/99-whalian

COPY \
	--chmod=755 \
	provision.sh \
	/usr/local/bin/provision

RUN /usr/local/bin/provision

COPY \
	gbp.conf \
	/etc/git-buildpackage/gbp.conf

COPY \
	--chmod=755 \
	build.sh \
	/usr/local/bin/build

COPY \
	--chmod=755 \
	gbp-builder.sh \
	/usr/local/bin/gbp-builder

ENTRYPOINT [ "/usr/local/bin/build" ]
