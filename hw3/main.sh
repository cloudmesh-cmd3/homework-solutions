

module load openstack
source ~/.cloudmesh/clouds/india/juno/openrc.sh

set -x

NAME=$USER-test
FLAVOR=m1.small
IMAGE=futuresystems/ubuntu-14.04
KEY="host_india contact_badi_AT_iu_edu"
DELAY=10s

SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

###################################################################### boot
nova boot --flavor $FLAVOR --image $IMAGE --key_name "$KEY" $NAME
sleep $DELAY

while true; do
    export IP=$(nova show $NAME | grep 'int-net network' | awk '{print $5}')
    test ! -z $IP && break
    sleep 20s # not ideal, but needs to be >15s to avoid flooding API calls
done
echo $IP

while ! nc -zv $IP 22; do
    sleep $DELAY
done

###################################################################### run
# forward ssh agent
eval $(ssh-agent -s)
ssh-add

# copy relevant files
scp $SSH_ARGS cloudmesh_ex{1,2}.py ubuntu@$IP:

cat >run.sh<<EOF
set -x
set -e
curl https://raw.githubusercontent.com/cloudmesh/get/master/cloudmesh/ubuntu/14.04.sh | venv=\$HOME/ENV bash
source \$HOME/ENV/bin/activate

PORTALNAME=$USER # $USER is evaluated on india but executed on VM
cm-iu user fetch --username=\$PORTALNAME
cm-iu user create

cd cloudmesh
fab india.configure


# "fab mongo.reset" wrapped with expect to set password students DO
# NOT NEED expect! this is just to automate also, the password is
# hardcoded here, but this SHOULD NOT be done for a real setup

sudo apt-get install -y expect
expect - <<EOS
set timeout -1
spawn fab mongo.reset
match_max 100000
expect -exact "Password:"
send -- "asdfasdf\r"
expect -exact "Enter again to confirm:"
send -- "asdfasdf\r"
expect eof
EOS

fab server.start
sleep 10s
curl localhost:5000

####  reset
cd


#### ex1
python cloudmesh_ex1.py

#### ex2
python cloudmesh_ex2.py

EOF

scp $SSH_ARGS run.sh ubuntu@$IP:
ssh -A $SSH_ARGS ubuntu@$IP bash run.sh

# don't leave agent hanging around :security:
ssh-agent -k