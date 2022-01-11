#!/usr/bin/env bash

set \
	-e \
	-o pipefail \
	#

declare -i \
	exit_code=0 \
	#

function show_usage
{
	echo 'usage:  whalian DISTRO RELEASE' >&2
}

if [[ $@ = ?(-)?(-)help ]]
then
	show_usage
elif [[ $# -eq 2 ]]
then
	declare \
		-r \
		-- \
		distro="$1" \
		release="$2" \
		#

	declare \
		-r \
		-- \
		artifact_directory=".whalian/${distro}/${release}" \
		#

	declare \
		-a \
		-- \
		docker_run_extra_arguments \
		#

	rm \
		--force \
		--recursive \
		-- \
		"${artifact_directory}" \
		#

	mkdir \
		--parents \
		-- \
		"${artifact_directory}" \
		#

	echo \
		'*' \
		> "${artifact_directory}/.gitignore" \
		#

	if [[ -t 1 ]]
	then
		# running in a terminal

		# --tty for colors
		docker_run_extra_arguments+=(
			--tty
		)
	fi

	if [[ -v DEB_SIGN_KEYID ]]
	then
		# key passed; build packages and sign them

		mapfile \
			-n 2 \
			-t \
			-- \
			gpg_paths \
			< <(
				gpgconf \
					--list-dirs \
					agent-socket \
					homedir \
					#
			) \
			#
		gpg_agent_socket="${gpg_paths[0]}"
		gpg_homedir="${gpg_paths[1]}"

		docker_run_extra_arguments+=(
			--env DEB_SIGN_KEYID
			--mount "type=bind,source=${gpg_homedir}/trustdb.gpg,target=/root/.gnupg/trustdb.gpg,readonly"
			--mount "type=bind,source=${gpg_homedir}/pubring.kbx,target=/root/.gnupg/pubring.kbx,readonly"
			--mount "type=bind,source=${gpg_agent_socket},target=/root/.gnupg/S.gpg-agent,readonly"
		)
	fi

	container_name="whalian-${distro}.${release}-${SRANDOM}"

	function cleanup
	{
		docker \
			container \
			rm \
			--force \
			-- \
			"${container_name}" \
			#
	}

	trap cleanup EXIT

	docker \
		run \
		--mount "type=bind,source=${PWD},target=/usr/src,readonly" \
		--name "${container_name}" \
		"${docker_run_extra_arguments[@]}" \
		-- \
		"ghcr.io/kalrish/whalian:${distro}-${release}" \
	|&
	{
		if [[ -t 1 ]]
		then
			# stdout is connected to a terminal, so `docker run` got the `--tty` option.
			# Therefore, logs may contain escape sequences that must be filtered out
			# of the saved log file.
			tee \
				-- \
				>(
					# remove escape sequences
					sed \
						-e 's/\x1b\[[0-9;]*[mGKH]//g' \
						> "${artifact_directory}/logs" \
						#
				) \
				#
		else
			# stdout is not connected to a terminal, so `docker run` didn't get the `--tty` option.
			# Therefore, it shouldn't be necessary to filter the build log.
			tee \
				-- \
				"${artifact_directory}/logs" \
				#
		fi
	} >&2

	echo "whalian: info: build log saved to ${artifact_directory}/logs" >&2

	docker \
		container \
		cp \
		-- \
		"${container_name}:/mnt/." \
		"${artifact_directory}" \
		#

	echo "whalian: info: build artifacts saved to ${artifact_directory}" >&2
else
	show_usage
	exit_code=1
fi

exit ${exit_code}
