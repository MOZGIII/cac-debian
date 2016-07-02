#!/bin/bash
set -e

SSH_HOST="$1"

if [[ -z "$SSH_HOST" ]]; then
  echo >&2 "Usage: $0 ssh-host"
  exit 2
fi

escape() {
  sed -r 's/(\\|\$|")/\\&/g'
}

REPOS_TEMPLATE="$(cat <<SOURCES
deb http://httpredir.debian.org/debian \$LSB_RELEASE_CODE main contrib non-free
deb-src http://httpredir.debian.org/debian \$LSB_RELEASE_CODE main contrib non-free

deb http://httpredir.debian.org/debian \$LSB_RELEASE_CODE-updates main contrib non-free
deb-src http://httpredir.debian.org/debian \$LSB_RELEASE_CODE-updates main contrib non-free

deb http://security.debian.org/ \$LSB_RELEASE_CODE/updates main contrib non-free
deb-src http://security.debian.org/ \$LSB_RELEASE_CODE/updates main contrib non-free

deb http://httpredir.debian.org/debian \$LSB_RELEASE_CODE-backports main contrib non-free
deb-src http://httpredir.debian.org/debian \$LSB_RELEASE_CODE-backports main contrib non-free
SOURCES
)"

CMD='LSB_RELEASE_CODE=$(lsb_release -cs)'
CMD="$CMD && "'echo \"'"$(echo "$REPOS_TEMPLATE" | escape)"'\"'
CMD="$CMD | tee /etc/apt/sources.list"
ssh "root@$SSH_HOST" "bash -ec \"$CMD\""
