#!/bin/sh
#
# crypto = openssl or botan
# objstore = file or sqlite

export CRYPTO=${1:-openssl}
export OBJSTORE=${2:-file}

sudo apt-get install build-essential autoconf automake libtool libcppunit-dev libsqlite3-dev sqlite3 libssl-dev libbotan1.10-dev

for repo in SoftHSMv2 p11speed; do
	if [ -d $repo -a -f $repo/.travis.sh ]; then
		cd $repo; sh .travis.sh
	else
		echo "$repo not found"
		exit 1
	fi
done
