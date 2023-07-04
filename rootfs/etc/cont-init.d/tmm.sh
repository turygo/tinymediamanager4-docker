#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Make sure mandatory directories exist.
mkdir -p /config/logs

# Check if the VERSION file exists in the /config directory.
# If not, create it and set its content to 0.
if [ ! -f /config/VERSION ]; then
    echo "0" > /config/VERSION
fi

# Get the installed version from the VERSION file.
installed_version=$(cat /config/VERSION)

# Get the downloaded version from the name of the tmm tarball.
# This assumes the tarball's name is in the format "tmm_VERSION_linux-amd64.tar.gz".
downloaded_version=$(ls /defaults/tmm_*.tar.gz | sed -n -e 's/^.*tmm_\([0-9\.]*\).tar.gz$/\1/p')

# Compare the installed and downloaded versions.
if [ "$downloaded_version" != "$installed_version" ]; then
    # If the versions differ, extract the new version and update the VERSION file.
    cp -r /defaults/* /config/
    cd /config
    tar --strip-components=1 -zxvf /config/tmm_${downloaded_version}.tar.gz
    echo $downloaded_version > /config/VERSION
fi

# Take ownership of the config directory content.
chown -R $USER_ID:$GROUP_ID /config/*

# Take ownership of the output directory.
#if ! chown $USER_ID:$GROUP_ID /output; then
    # Failed to take ownership of /output.  This could happen when,
    # for example, the folder is mapped to a network share.
    # Continue if we have write permission, else fail.
#    if s6-setuidgid $USER_ID:$GROUP_ID [ ! -w /output ]; then
#        log "ERROR: Failed to take ownership and no write permission on /output."
#        exit 1
#    fi
#fi

# vim: set ft=sh :
