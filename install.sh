#!/bin/bash -e

# Install Nginx with this Guide.

set -e


# Sanity Checks
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Must be run with root privileges."
    exit 1
fi

# Only for Ubuntu 12.04
source /etc/lsb-release
if [ "$DISTRIB_ID" != "Ubuntu" -o "$DISTRIB_RELEASE" != "12.04" ]; then
    echo "ERROR: Only Ubuntu 12.04 is supported."
    exit 1
fi


set -x


# Install nginx
apt-get update

apt-get upgrade

# apt-get install -y nginx
cat <<PACKAGES | xargs apt-get install -y
nginx
PACKAGES

# Service stop if upstart
for port in 80 443; do
	while ! nc -vz localhost $port; do
		sleep 1
	done
doen

service nginx stop


# Copy Nginx share file for default Virtual-Host
