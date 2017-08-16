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

NET_ETH=ens3
WORKER_TYPE=m3.medium
NUM_WORKERS=4
WORKER_MACHINE_NAME=${CLUSTER_PREFIX}-worker-

KEYSTORE_IP=$(aws ec2 describe-instances | jq -r ".Reservations[].Instances[] | select(.KeyName==\"${CLUSTER_PREFIX}consul\" and .State.Name==\"running\") | .PrivateIpAddress")

SWARM_OPTIONS="--swarm --swarm-discovery=consul://$KEYSTORE_IP:8500"
#--engine-opt=cluster-store=consul://$KEYSTORE_IP:8500 --engine-opt=cluster-advertise=$NET_ETH:2376"


DRIVER_OPTIONS="--driver amazonec2 --amazonec2-security-group=dockersparkswarm 
                      --amazonec2-access-key $MY_ACCESS_KEY 
                      --amazonec2-secret-key $MY_SECRET_ACCESS_KEY 
                      --amazonec2-region eu-central-1 --amazonec2-vpc-id $VPCID"

WORKER_OPTIONS="$DRIVER_OPTIONS $SWARM_OPTIONS --amazonec2-instance-type=$WORKER_TYPE"

MASTER_MACHINE_NAME=${CLUSTER_PREFIX}-master
WORKER_MACHINE_NAME=${CLUSTER_PREFIX}-worker-

MASTER_IP=$(aws ec2 describe-instances  | jq -r ".Reservations[].Instances[] | select(.KeyName==\"${MASTER_MACHINE_NAME}\" and .State.Name==\"running\") | .PrivateIpAddress")


# get swarm token to add workers to the Swarm
TOKEN=$(docker-machine ssh $MASTER_MACHINE_NAME sudo docker swarm join-token worker -q)

echo "Got Swarm Token : $TOKEN"

for INDEX in $(seq $NUM_WORKERS)
do ( docker-machine create $WORKER_OPTIONS $WORKER_MACHINE_NAME$INDEX
     docker-machine ssh $WORKER_MACHINE_NAME$INDEX "sudo docker swarm join --token $TOKEN $MASTER_IP:2377"
     #docker-machine ssh $WORKER_MACHINE_NAME$INDEX "sudo docker exec -it /bin/bash"
   ) &
done
wait
