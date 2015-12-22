FROM ubuntu:trusty
MAINTAINER Max Mongardini <max@last.fm>
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tofrodos bsd-mailx python-software-properties software-properties-common python2.7 python-dev libperl-dev mysql-client libapache2-mod-php5 python-setuptools nano mc vim-tiny php5-curl php5-memcached php5-geoip php5-gd php5-ldap php5-imap php5-pgsql php5-mcrypt sudo heirloom-mailx lsb-release build-essential cmake gsoap zlib1g-dev libxerces-c-dev apache2 apache2-mpm-prefork php5 php5-mysql php5-sqlite php-pear php5-ldap php5-snmp php5-gd php5-intl libmysqlclient-dev rrdtool librrds-perl libconfig-inifiles-perl libcrypt-des-perl libdigest-hmac-perl libdigest-sha-perl libgd-gd2-perl snmp snmpd libnet-snmp-perl libsnmp-perl libgd2-xpm-dev libpng12-dev exim4 wget iputils-ping smbclient libssl-dev dnsutils fping less vim net-tools rsyslog supervisor libjson-perl cron libqt4-network libqtcore4 libqt4-dev libqt4-sql-mysql libgnutls28-dev librrd-dev dialog telnet netcat libevent-2.0-5 python-pip git libffi-dev curl libssh2-1-dev libgcrypt11-dev postgresql-server-dev-all openssh-server openssh-client libmysqlclient18 libdatetime-perl libgd-perl

# TODO add the non-free packages
# RUN DEBIAN_FRONTEND=noninteractive apt-get -y install snmp-mibs-downloader

# generic RUNs
RUN mkdir /root/centreon ; groupadd centreon ; useradd -g centreon -m -r -d /var/lib/centreon centreon 
ADD files/php-timezone.ini /etc/php5/apache2/conf.d/00-timezone.ini

# centreon-clib-dev
WORKDIR /root/centreon
ENV CENTREON_CLIB 1.4.2
RUN wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-clib/centreon-clib-${CENTREON_CLIB}.tar.gz && tar zxf centreon-clib-${CENTREON_CLIB}.tar.gz && cd centreon-clib-${CENTREON_CLIB}/build && cmake . && make && make install

# centreon-engine, nagios replacement (fork)
WORKDIR /root/centreon
ENV CENTREON_ENG 1.5.0
RUN wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-engine/centreon-engine-${CENTREON_ENG}.tar.gz && tar zxf centreon-engine-${CENTREON_ENG}.tar.gz && cd centreon-engine-${CENTREON_ENG}/build && cmake -DWITH_CENTREON_CLIB_LIBRARY_DIR=/usr/local/lib -DWITH_USER=centreon -DWITH_GROUP=centreon -DWITH_PREFIX=/usr/local/centreon/centreon-engine -DWITH_PREFIX_CONF=/etc/centreon/centreon-engine -DWITH_STARTUP_DIR=/etc/init.d -DWITH_LOGROTATE_SCRIPT=1 -DWITH_WEBSERVICE=1 -DWITH_SSL=1 . && make && make install

# centreon-broker replacement for ndo2db
WORKDIR /root/centreon
ENV CENTREON_BRK 2.11.0
RUN wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-broker/centreon-broker-${CENTREON_BRK}.tar.gz && tar zxf centreon-broker-${CENTREON_BRK}.tar.gz && cd centreon-broker-${CENTREON_BRK}/build && cmake -DWITH_DAEMONS='central-broker;central-rrd' -DWITH_GROUP=centreon -DWITH_USER=centreon -DWITH_PREFIX=/usr/local/centreon/centreon-broker -DWITH_PREFIX_CONF=/etc/centreon/centreon-broker -DWITH_STARTUP_DIR=/etc/init.d . && make && make install && mkdir /usr/local/centreon/centreon-broker/retention && chown centreon:centreon /usr/local/centreon/centreon-broker/retention

# centreon ssh,perl,icmp connectors
WORKDIR /root/centreon
ENV CENTREON_CONN 1.1.2
RUN wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-connectors/centreon-connector-${CENTREON_CONN}.tar.gz && tar zxf centreon-connector-${CENTREON_CONN}.tar.gz && for c in ssh perl ; do cd centreon-connector-${CENTREON_CONN}/${c}/build && cmake -DWITH_PREFIX=/usr/local/centreon/centreon-connectors . && make && make install ; cd /root/centreon/ ; done 

ADD files/restart-centreon.sh /restart-centreon.sh
RUN chmod +x /restart-centreon.sh

# centreon frontend
WORKDIR /root/centreon
ENV CENTREON_UI 2.7.0
ADD files/centreon-silent-install.txt /root/centreon/centreon-silent-install.txt
RUN wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon/centreon-web-${CENTREON_UI}.tar.gz && mkdir -p /usr/local/nagios/libexec && chown centreon:centreon /usr/local/nagios/libexec && tar xzf centreon-web-${CENTREON_UI}.tar.gz && cd centreon-web-${CENTREON_UI} && ./install.sh -f ../centreon-silent-install.txt
ADD files/centreon-engine_install /usr/local/centreon/centreon-core/www/install/var/engines/centreon-engine
ADD files/centreon-broker_install /usr/local/centreon/centreon-core/www/install/var/brokers/centreon-broker
ADD files/install_conf_php /usr/local/centreon/centreon-core/www/install/install.conf.php

# centreon clapi
WORKDIR /root/centreon
ENV CENTREON_CLAPI 1.8.0
RUN wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/Modules/CLAPI/centreon-clapi-${CENTREON_CLAPI}.tar.gz && tar zxvf centreon-clapi-${CENTREON_CLAPI}.tar.gz && cd centreon-clapi-${CENTREON_CLAPI}/ && ./install.sh -u /etc/centreon/centreon-core

# nagios plugins
WORKDIR /root/centreon
ENV NAG_PLUGINS 2.1.1
RUN wget http://www.nagios-plugins.org/download/nagios-plugins-${NAG_PLUGINS}.tar.gz
RUN tar zxf nagios-plugins-${NAG_PLUGINS}.tar.gz && cd nagios-plugins-${NAG_PLUGINS} && ./configure --with-nagios-user=centreon --with-nagios-group=centreon  2>&1 | tail -n 10 && make 2>&1 | tail -n 10 && make install

# some fixes
RUN chmod 775 /etc/centreon/centreon-engine/objects/
RUN test -d /var/log/centreon || mkdir /var/log/centreon
RUN chown centreon:centreon /var/log/centreon && chmod 777 /var/log/centreon && mkdir /usr/local/centreon/centreon-engine/service-perfdata && chown -R centreon:centreon /usr/local/centreon/centreon-engine/service-perfdata

# install java
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-get -y install oracle-java7-installer
#
## ADD /var/cache/oracle-jdk7-installer/
#
#ADD files/bashrc /.bashrc

#add all custom plugins
ADD nagios-plugins/* /usr/local/nagios/libexec/

#add pagerduty flush cron, by default the cron is disabled in the cron file
ADD files/pagerduty.cron /etc/cron.d/pagerduty

#add check_by_ssh master 
WORKDIR /root/centreon
RUN git clone https://github.com/osklil/nagios-misc.git && cd nagios-misc/check_by_ssh_master/ && make && mv check_by_ssh_master /usr/local/nagios/libexec/

ADD files/widgets.tgz /usr/local/centreon/centreon-core/www/widgets
RUN chown -R centreon:centreon /usr/local/centreon/centreon-core/www/widgets

#fix exim4 smarthost, edit files/start.sh to set the right smarthost and redirect_to
COPY files/exim4.conf.tpl /etc/exim4/exim4.conf.tpl

#fix sshd locales overwrite, this to allow ssh into the docker container, controversial, but useful to test checks
RUN sed -i -e"s/^AcceptEnv LANG LC_\*/#AcceptEnv LANG LC_*/" /etc/ssh/sshd_config


#add ssl to apache
#RUN cd /etc/apache2/mods-enabled/ && ln -sf ../mods-available/ssl* .
#RUN mkdir /etc/apache2/ssl
#ADD files/sslcert.crt /etc/apache2/ssl/
#ADD files/sslcert.key /etc/apache2/ssl/
#ADD files/sslcert_chain.crt /etc/apache2/ssl/
#RUN chown -R www-data:www-data /etc/apache2/ssl/ && chmod 600 /etc/apache2/ssl/sslcert.key
#ADD files/default-ssl /etc/apache2/sites-enabled/default-ssl

ADD files/start.sh /start.sh
ADD files/foreground.sh /etc/apache2/foreground.sh
ADD files/supervisord.conf /etc/supervisord.conf
RUN chmod 755 /start.sh
RUN chmod 755 /etc/apache2/foreground.sh
RUN mkdir -p /usr/local/centreon/status/www/
ADD files/naglite/* /usr/local/centreon/status/www/
#add basic auth to naglite
#ADD files/status_access /usr/local/centreon/status/www/.htaccess
#ADD files/status_access.htpasswd /etc/centreon/status_access
ADD files/apache2_ports.conf /etc/apache2/ports.conf
ADD files/000-default /etc/apache2/sites-available/000-default.conf
ADD files/apache_centreon /etc/apache2/conf-enabled/centreon.conf
#ADD a private/pub key for check_by_ssh
#RUN mkdir /home/centreon/.ssh && chmod 700 /home/centreon/.ssh && chown centreon:centreon /home/centreon/.ssh
#ADD files/id_dsa /home/centreon/.ssh/id_dsa
#ADD files/id_dsa.pub /home/centreon/.ssh/id_dsa.pub
#RUN chmod 600 /home/centreon/.ssh/id_dsa 
RUN mkdir /root/.ssh && chmod 700 /root/.ssh
ADD files/authorized_keys /root/.ssh/authorized_keys
RUN mkdir /var/run/sshd

EXPOSE 8080
EXPOSE 22

CMD ["/bin/bash", "/start.sh"]
