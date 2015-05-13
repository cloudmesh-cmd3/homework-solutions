#!/usr/bin/env bash

module load openstack
source ~/.cloudmesh/clouds/india/juno/openrc.sh

set -x

STACK_NAME=heat-lab-ex1-solution
KEY='host_india contact_badi_AT_iu_edu'


INSTANCE_NAME=instance
INSTANCES=2
DELAY=15s

###################################################################### util functions
get-vm-id() {
    local name_pattern=$1
    nova list | grep $name_pattern | awk '{print $2}'
}

get-int-ip() {
    local id=$1
    nova show $id | grep 'int-net network' | awk '{print $5}'
}

###################################################################### boot
heat stack-create \
    --template-file heat_ex1.yaml \
    -P key_name="$KEY" \
    $STACK_NAME


###################################################################### get ip addresses
ADDRESSES=
for i in `seq $INSTANCES`; do

    while true; do
	id=$(get-vm-id $STACK_NAME-$INSTANCE_NAME$i)
	test ! -z $id && break
	sleep $DELAY
    done

    while true; do
	ip=$(get-int-ip $id)
	test ! -z $ip && break
	sleep $DELAY
    done
    ADDRESSES="$ADDRESSES $ip"
done

###################################################################### wait for machines to start

# the assumption is that once sshd is running and listening on port 22
# then the machine is up

for addr in $ADDRESSES; do    
    while ! nc -zv $addr 22; do
	sleep $DELAY
    done
done

###################################################################### check the ports

for addr in $ADDRESSES; do
    nmap $addr
done
