#!/usr/bin/env bash

set -x

sudo apt-get -y update
sudo apt-get -y install python{,-virtualenv,-pip}

virtualenv ~/ENV
source ~/ENV/bin/activate

pip install cherrypy

# simply running the example
# https://cherrypy.readthedocs.org/en/latest/install.html#test-your-installation
# will not work for us as it binds to 127.0.0.1 (just the localhost) and will only work
# by browsing to 127.0.0.1:8080 or localhost:8080.
#
# instead, update the configuration to use all address on this machine
#
# screen is used over nohup due to the nohuped command not executing:
# ssh $USER@$HOST <<EOF
# nohup command &
# EOF
screen -A -m -d -S cherrypy python -c "import cherrypy;cherrypy.config.update({'server.socket_host': '0.0.0.0'});cherrypy.quickstart()" 
