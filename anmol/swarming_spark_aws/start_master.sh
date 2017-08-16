#!/bin/bash

#Path to the private key produced on Mac OSX
# ~/.docker/machine/machines

set -e

red='\033[0;31m'
NC='\033[0m'

usage () {
	echo 
	echo -e "${red}Usage: $0 <path/to/file/aws_credentials>${NC}"
	echo "Format in credentials file should match the pattern: "
	echo "MY_ACCESS_KEY="**********""
	echo "MY_SECRET_ACCESS_KEY="*********""
	echo "VPCID="******""
	echo 
}

if [ $# -eq 0 ]
then
	usage
	exit 0
fi

# Read credentials file
source $1

CLUSTER_PREFIX=c1

NET_ETH=ens3

KEYSTORE_IP=$(aws ec2 describe-instances | jq -r ".Reservations[].Instances[] | select(.KeyName==\"${CLUSTER_PREFIX}consul\" and .State.Name==\"running\") | .PrivateIpAddress")

SWARM_OPTIONS="--swarm --swarm-host=tcp://0.0.0.0:4000 --swarm-discovery=consul://$KEYSTORE_IP:8500"


# DEPRECATED
#--engine-opt=cluster-store=consul://$KEYSTORE_IP:8500 --engine-opt=cluster-advertise=$NET_ETH:2376"


DRIVER_OPTIONS="--driver amazonec2 --amazonec2-security-group=dockersparkswarm 
                      --amazonec2-access-key $MY_ACCESS_KEY 
                      --amazonec2-secret-key $MY_SECRET_ACCESS_KEY 
                      --amazonec2-region eu-central-1 --amazonec2-vpc-id $VPCID"

MASTER_OPTIONS="$DRIVER_OPTIONS $SWARM_OPTIONS --swarm-master -engine-label role=master --amazonec2-instance-type=m3.medium"

MASTER_MACHINE_NAME=${CLUSTER_PREFIX}-master


COMMAND="docker-machine create $MASTER_OPTIONS $MASTER_MACHINE_NAME"

echo " Command to create Master is :::: ${COMMAND}"

eval $COMMAND
eval $(docker-machine env $MASTER_MACHINE_NAME)

# get private ip of the master machine, you need a jq utility json parser
MASTER_IP=$(aws ec2 describe-instances  | jq -r ".Reservations[].Instances[] | select(.KeyName==\"${MASTER_MACHINE_NAME}\" and .State.Name==\"running\") | .PrivateIpAddress")
echo $MASTER_IP

# init the Swarm master
SWARM_INIT_COMMAND="docker-machine ssh $MASTER_MACHINE_NAME \"sudo docker swarm init --advertise-addr $MASTER_IP\""

eval $SWARM_INIT_COMMAND
		
