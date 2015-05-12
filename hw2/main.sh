

module load openstack
source ~/.cloudmesh/clouds/india/juno/openrc.sh

set -x

SCRIPT=cherrypy.sh
test ! -z $1 && SCRIPT=$1

if [ "$SCRIPT" == "apache.sh" ]; then
    WEB_PORT=80
elif [ "$SCRIPT" == "cherrypy.sh" ]; then
    WEB_PORT=8080
else
    echo "Unsupported script $SCRIPT" >&2
    exit 1
fi

NAME=$USER-test
FLAVOR=m1.small
IMAGE=futuresystems/ubuntu-14.04
KEY="host_india contact_badi_AT_iu_edu"
DELAY=10s

SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

###################################################################### open ports in security group
nova secgroup-add-rule default tcp 80 80 0.0.0.0/0
nova secgroup-add-rule default tcp 8080 8080 0.0.0.0/0

###################################################################### boot
nova boot --flavor $FLAVOR --image $IMAGE --key_name "$KEY" $NAME
sleep $DELAY

IP=
while test -z $IP; do
    export IP=$(nova show $NAME | grep 'int-net network' | awk '{print $5}')
    sleep 20s # not ideal, but needs to be >15s to avoid flooding API calls
done
echo $IP

while ! nc -zv $IP 22; do
    sleep $DELAY
done

###################################################################### install/configure
# copy main file
#scp $SSH_ARGS $SCRIPT ubuntu@$IP:run.sh

# run file
ssh $SSH_ARGS ubuntu@$IP <$SCRIPT


###################################################################### test
# the server may not immediately be up, so try a few times before bailing
for i in `seq 10`; do
    curl $IP:$WEB_PORT && break
    sleep $DELAY
done
