#!/bin/sh
#
# crypto = openssl or botan

CRYPTO=${1:-openssl}

CONF_CRYPTO=""
CONF_SOFTHSM="--with-objectstore-backend-db --disable-non-paged-memory"

# Select crypto backend
case $CRYPTO in
botan)
	CONF_CRYPTO="$CONF_CRYPTO --with-crypto-backend=botan --with-botan=/usr"
	;;
openssl)
	CONF_CRYPTO="$CONF_CRYPTO --with-crypto-backend=openssl --with-openssl=/usr"
	;;
*)
	echo "Unknown crypto backend"
	exit 1
esac

# Verify that we have the submodules
for repo in SoftHSMv2 p11speed; do
	if [ ! -d $repo -o ! -f $repo/autogen.sh ]; then
		echo "$repo not found"
		exit 1
	fi
done

# Get the dependencies
sudo apt-get install build-essential autoconf automake libtool libcppunit-dev libsqlite3-dev sqlite3 libssl-dev libbotan1.10-dev

# Build SoftHSMv2
cd SoftHSMv2 && \
sh autogen.sh && \
./configure $CONF_CRYPTO $CONF_SOFTHSM && \
make all check

# Build p11speed
cd ../p11speed && \
sh autogen.sh && \
./configure && \
make all
