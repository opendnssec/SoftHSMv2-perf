#!/bin/sh

provider=SoftHSMv2/src/lib/.libs/libsofthsm2.so

token_slot=0
token_label=performance
user_pin=1234
so_pin=1234567890

iterations=1000
threads=1

softhsm2_util="SoftHSMv2/src/bin/util/softhsm2-util --module $provider"
p11speed="time p11speed/src/bin/p11speed --sign --module $provider --slot $token_slot --pin $user_pin"

$softhsm2_util --init-token \
	--force \
	--slot $token_slot \
	--label $token_label \
	--pin $user_pin \
	--so-pin $so_pin

p11speed() {
	iterations=$1
	threads=$2
	mechanism=$3
	keysize=$4

	case $mechanism in
	RSA_PKCS)
		$p11speed --iterations $iterations --threads $threads \
			--mechanism $mechanism --keysize $keysize 
		;;
	ECDSA)
		$p11speed --iterations $iterations --threads $threads \
			--mechanism $mechanism --keysize $keysize 
		;;
	GOSTR3410)
		$p11speed --iterations $iterations --threads $threads \
			--mechanism $mechanism
		;;
	*)
		echo "unknown mechanism"
		return 0
		;;
	esac
}

p11speed 10000 1 RSA_PKCS 1024
p11speed  1000 1 RSA_PKCS 2048
p11speed   100 1 RSA_PKCS 4096

p11speed 1000 1 ECDSA 256
p11speed 1000 1 ECDSA 384

p11speed 10000 1 GOSTR3410

