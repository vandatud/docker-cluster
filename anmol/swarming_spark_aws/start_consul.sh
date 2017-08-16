#!/bin/bash

#Path to the private key produced
# ~/.docker/machine/machines


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

#Read credentials file
source $1

CLUSTER_PREFIX=c1

docker-machine create --driver amazonec2 \
                      --amazonec2-security-group=dockersparkswarm \
                      --amazonec2-access-key $MY_ACCESS_KEY \
                      --amazonec2-secret-key $MY_SECRET_ACCESS_KEY \
                      --amazonec2-region eu-central-1 --amazonec2-vpc-id $VPCID \
                      --amazonec2-instance-type=t2.nano ${CLUSTER_PREFIX}consul

COMMAND="docker $(docker-machine config ${CLUSTER_PREFIX}consul) run -d -p 8400:8400 -p "8500:8500" -p 8600:53/udp -h "consul" progrium/consul -server -bootstrap -ui-dir /ui"

eval $COMMAND
