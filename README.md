# Dockerized Centreon

This docker-compose will run a docker container for centreon and a docker container for mysql

The mysql container will have the mysql data mapped to /var/lib/centreon/mysql and will expose the mysql port on 13306.

The centreon container will have /var/log/centreon mapped and will expose ssh on port 2222 and the UI on 8080.

## Configuration

* Add your ssh public key to centreon-docker/files/authorized_keys

* Edit the file centreon-docker/files/start.sh with the correct smtp smart-host settings for exim

```
[ x$SMARTHOST = x ]      && SMARTHOST=smtp
[ x$REDIRECT_TO = x ]      && REDIRECT_TO=root@localhost
```
* Change and copy the mysql password set in docker-compose.yml

* Add any custom checks to centreon-docker/nagios-plugins/

* It should be possible to enable ssl by adding the certs in the locations specified in centreon-docker/Dockerfile but will need some testing

## Building the image

	docker-compose build 

## Running the containers

	docker-compose up -d

The centreon container needs to run as a privileged container stems from the need to increase the `kernel.msgmnb` parameter.

The Centreon daemon `centcore` will not start to begin with and end up in a supervisord-FATAL state. That is expected, as the following setup will need to create the configuration files first. 

## Setting up Centreon for the first time

Once the container is running, connect to the UI:

	http://host-server.example.com:8080/centreon/

Centreon will start the setup process. 

Here you will need the MySQL root user password, this is located in the docker-compose.yml file.

Most of the field are already pre-set for this setup, with the exception of the following values:
> Admin user and password: *You pick...*

> Database Host Address (default: localhost): *mysql*

> Root password: *[check the docker-compose.yml file]*

> centreon db user and passwords: *up to you...*

Once the wizard is finished, it will start from the beginning again. This is a bug in the installation part when run the way this is setup.
To bypass this, restart the container once the installation wizard goes to the beginning.
	docker restart centreon_centreon_1

Now you will be able to login to the interface with the admin user and password set
Once logged in, there are a couple of tweaks to have a working configuration:

* Go to Configuration -> Pollers -> Engine Configuration (left pane) -> Centreon Engine CFG 1
  * Change "Log file" to "/var/log/centreon/centengine.log"
  * On the Debug tab, change "Debug File" to "/var/log/centreon/centengine.debug"
  * Hit Save

* Go to Configuration -> Pollers -> Broker Configuration (left pane) -> Central Broker master
  * Hit Save

* Go to Configuration -> Pollers -> Broker Configuration (left pane) -> Central Broker rrd
  * Hit Save

* Go to Configuration -> Pollers -> Central Poller, Action icon (right)
  * Select all the checkboxes
  * Hit "Export"

* Restart the docker container
	docker restart centreon_centreon_1
 
## TODO

* Create a supervisord friendly start script for cbd
* Check why /var/log/centreon is not owned by centreon, current workaround in start.sh



