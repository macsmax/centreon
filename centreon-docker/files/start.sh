#!/bin/bash

yes n | cp -i /root/centreon-etc/inst* /etc/centreon/ 2> /dev/null

# Stop Centreon stumbling over its own feet...
if [ -f /etc/centreon/centreon-core/conf.pm ]
then
        # Configuration was completed, so try to move the install directory out of the way.
        if [ -d /usr/local/centreon/centreon-core/www/install ]
        then
                mv /usr/local/centreon/centreon-core/www/install /usr/local/centreon/centreon-core/www-install.deactivated
        fi
fi

cron -f &

#crontab /root/centreon.cron
# exim4

exim-list(){
  local res="$1"
  shift
  for item in "$@"; do
    res="$res : $item"
  done
  printf %s "$res"
}

#change SMARTHOST and REDIRECT_TO to something meaningful

[ x$LOCAL_DOMAINS = x ] && LOCAL_DOMAINS=localhost:localhost.localdomain
[ x$RELAY_DOMAINS = x ] && RELAY_DOMAINS=$LOCAL_DOMAINS
[ x$MAILNAME = x ]      && MAILNAME=centreon
[ x$RELAY_NETWORKS = x ] && RELAY_NETWORKS=127.0.0.0/24:127.1.0.0/24
[ x$SMARTHOST = x ]      && SMARTHOST=smtp
[ x$REDIRECT_TO = x ]      && REDIRECT_TO=root@localhost
sed -e "s|%LOCAL_DOMAINS%|$(exim-list $LOCAL_DOMAINS)|g" \
    -e "s|%RELAY_DOMAINS%|$(exim-list $RELAY_DOMAINS)|g" \
    -e "s|%MAILNAME%|$(exim-list $MAILNAME)|g" \
    -e "s|%RELAY_NETWORKS%|$(exim-list $RELAY_NETWORKS)|g" \
    -e "s|%SMARTHOST%|$(exim-list $SMARTHOST)|g" \
    -e "s|%REDIRECT_TO%|$(exim-list $REDIRECT_TO)|g" \
    /etc/exim4/exim4.conf.tpl \
    >/etc/exim4/exim4.conf

chown centreon:centreon /var/log/centreon

sysctl -w kernel.msgmnb=655360 # without that, ndo2db will fail to work and no services or hosts will show up in Centreon, Monitoring tab
supervisord -n -c /etc/supervisord.conf -e debug 

