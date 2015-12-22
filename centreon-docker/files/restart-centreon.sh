#!/bin/bash
#COMMAND=$1
COMMAND=restart
pidFile=/var/run/centreon/centengine.pid
supervisorctl -c /etc/supervisord.conf $COMMAND centengine
pid=`pidof centengine`
echo $pid > $pidFile
