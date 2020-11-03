#!/bin/sh
mkdir -p ~/.gem/

if [ -z "${GEM_HOST_API_KEY}" ]
then
	echo "ERROR: GEM_HOST_API_KEY is not set"
	exit 1
else
	echo "--- \n:rubygems_api_key: ${GEM_HOST_API_KEY}" > ~/.gem/credentials
	chmod 600 ~/.gem/credentials
	timeout -k 10m 00s gem push fluentd-plugin-annotation-filter-${VERSION}.gem
fi
