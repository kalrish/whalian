FROM ubuntu:20.04

WORKDIR /usr/src

COPY \
	--chmod=755 \
	provision.sh \
	/usr/local/bin/provision

RUN /usr/local/bin/provision

COPY \
	--chmod=755 \
	build.sh \
	/usr/local/bin/build

COPY \
	--chmod=755 \
	gbp-builder.sh \
	/usr/local/bin/gbp-builder

COPY \
	debsig-policy.xml \
	/usr/local/share/debsig-policy.xml

ENTRYPOINT [ "/usr/local/bin/build" ]
