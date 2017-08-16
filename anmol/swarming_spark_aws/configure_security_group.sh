#!/bin/bash

set -e
red='\033[0;31m'
NC='\033[0m'

usage () {
	echo
	echo -e "${red}Usage: $0 <path/to/file/aws_credentials>${NC}"
	echo "Format in credentials file should match the pattern: "
	echo "MY_ACCESS_KEY="**********""
	echo "MY_SECRET_ACCESS_KEY="************""
	echo "VPCID="******""
	echo
}

if [ $# -eq 0 ]
then
	usage
	exit 0
fi


docker-machine create --driver amazonec2 \
	--amazonec2-security-group=dockersparkswarm \
	--amazonec2-access-key $MY_ACCESS_KEY\
	--amazonec2-secret-key $MY_SECRET_ACCESS_KEY\
	--amazonec2-region eu-central-1 \
	--amazonec2-vpc-id $VPCID \
	--amazonec2-open-port 2377 \
	--amazonec2-open-port 7946 \
	--amazonec2-open-port 4789 \
	--amazonec2-open-port 7946/udp --amazonec2-open-port 4789/udp \
	--amazonec2-open-port 8080 --amazonec2-open-port 80 \
	--amazonec2-open-port 8300 --amazonec2-open-port 8301 \
	--amazonec2-open-port 8302 --amazonec2-open-port 8400 \
	--amazonec2-open-port 8500 --amazonec2-open-port 8600 \
	--amazonec2-open-port 443 ports

docker-machine rm --force ports
