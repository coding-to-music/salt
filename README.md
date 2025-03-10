# salt

## 🚀 Salt Stack formulas for salt-master and salt-minion 🚀

https://github.com/coding-to-music/salt

From / By

## Environment variables

```java

```

## GitHub

```java
git init
git add .
git remote remove origin
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:coding-to-music/salt.git
git push -u origin main
```

## Useful commands

```java
sudo salt-run fileserver.update
sudo salt-run fileserver.file_list
sudo salt-run fileserver.file_list | grep '.sls'

sudo systemctl restart salt-master
sudo systemctl status salt-master

sudo journalctl -xeu salt-master.service
sudo journalctl -u salt-master
sudo tail -f /var/log/salt/master

sudo systemctl restart salt-minion
sudo systemctl status salt-minion

sudo journalctl -xeu salt-minion.service
sudo journalctl -u salt-minion
sudo tail -n 20 -f /var/log/salt/minion

# view lines that do not begin with # and are not blank lines
grep -v -e '^#' -e '^$' /etc/salt/master
grep -v -e '^#' -e '^$' /etc/salt/minion
```

## accept keys so the master and minions see each other

list accepted keys

```java
sudo salt-key -L
```

remove keys from a minion

```java
sudo salt-key -d minion_name
```

## Applying the States

Apply states from the base environment:

```java
sudo salt '*' state.apply test saltenv=base
sudo salt '*' state.apply vim saltenv=base
sudo salt '*' state.apply timezone saltenv=base
```

Apply states from the dev environment:

```java
sudo salt '*' state.apply influxdb.v2.upgrade saltenv=dev
sudo salt '*' state.apply webserver.apache2.install saltenv=dev
```

## Overall task list

### Server basic setup

- [ ] set hostname
- [ ] set time zone to NYC
- [ ] remote mount a drive
- [ ] setup drive rsync

### Users

- [ ] install ssh keys
- [ ] disable root login
- [ ] create user for myself
- [ ] .bash_aliases for myself
- [ ] sudo for myself
- [ ] create user docker
- [ ] create user grafana

### cli Software

- [ ] github git
- [ ] gh github login
- [ ] vercel
- [ ] cloudflare

### systemctl processes

- [ ] node-exporter
- [ ] grafana alloy
- [ ] ufw firewall
- [ ] docker
- [ ] fail2ban

### environment software

- [ ] nvm
- [ ] node
- [ ] yarn
- [ ] pnpm
- [ ] deno
- [ ] pyenv
- [ ] python3

### Salt-Stack
- [ ] Pillars
- [ ] Grains
- [ ] Hashicorp Vault


### databases & more

- [ ] Grafana 
    - [ ] Dashboards
    - [ ] Grafana Auth
    - [ ] Data Sources
    - [ ] Users
- [ ] Webserver
    - [X] apache2
        - [ ] Demo website
        - [ ] https certificate
        - [ ] Alloy Collector
        - [ ] Grafana Dashboard(s)
    - [X] nginx
        - [ ] Demo website
        - [ ] https certificate
        - [ ] Alloy Collector
        - [ ] Grafana Dashboard(s)
- [ ] MinIO 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [X] influxDB
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] postgresql
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] supabase
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] mongoDB
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] kafka
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Redis
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] k3s 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Docker 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] GitHub 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Cert Manager via k3s 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Cloudflare DNS 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Beyla
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Python Application
    - [ ] CPU Memory Disk Processes Grafana Dashboard(s)
    - [ ] Distribute via apt package
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)

## Backup hard drive

- [ ] rsync

### Other related repos for setups and installation

https://github.com/coding-to-music/saltstack-salt-in-10-minutes

https://github.com/coding-to-music/setup-linux-server-rsync-data-from-old-server

https://github.com/coding-to-music/install-virtualbox-on-digitalocean-or-contabo

https://github.com/coding-to-music/using-fail2ban-to-harden-linux-server

## k3s

https://docs.k3s.io/installation

https://computingforgeeks.com/installing-k3s-on-ubuntu-noble-numbat/

https://docs.k3s.io/installation/requirements?os=debian

Manual Install

```java
```



## Hashicorp Vault

https://portal.cloud.hashicorp.com/sign-in

https://developer.hashicorp.com/hcp/tutorials

https://developer.hashicorp.com/hcp/docs/vault-secrets/get-started/plan-implementation/tiers-features

Manual Install

https://developer.hashicorp.com/hcp/tutorials/get-started-hcp-vault-secrets/hcp-vault-secrets-install-cli

```java
```

## Redis

https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/

Manual Install

```java
sudo apt-get install lsb-release curl gpg
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install redis
```

Redis will start automatically, and it should restart at boot time. If Redis doesn't start across reboots, you may need to manually enable it:

```java
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

Connect to Redis
Once Redis is running, you can test it by running redis-cli:

redis-cli
Test the connection with the ping command:

127.0.0.1:6379> ping
PONG

https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/#install-redis-properly

https://redis.io/docs/latest/develop/tools/cli/

https://redis.io/docs/latest/develop/clients/

https://redis.io/docs/latest/develop/tools/insight/

https://redis.io/docs/latest/operate/redisinsight/install/

## Supabase

https://supabase.com/docs/guides/self-hosting

https://supabase.com/docs/guides/self-hosting/docker

https://supabase.com/docs/guides/local-development/cli/getting-started?queryGroups=platform&platform=linux

https://supabase.com/docs/guides/local-development?queryGroups=package-manager&package-manager=yarn

Manual Install

```java
```

## MongoDB

https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/

Manual Install

```java
# Import the public key
sudo apt-get install gnupg curl

curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

# Create the list file.
# Create the list file /etc/apt/sources.list.d/mongodb-org-8.0.list for your version of Ubuntu.
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list   

sudo apt-get update

sudo apt-get install -y mongodb-org

# check version
mongod --version
```

https://www.mongodb.com/docs/manual/tutorial/getting-started/#std-label-getting-started

https://www.mongodb.com/docs/mongodb-shell/

https://idroot.us/install-mongodb-ubuntu-24-04/

https://www.cherryservers.com/blog/install-mongodb-ubuntu-2404#step-6-create-mongodb-admin-user

https://www.cherryservers.com/blog/install-mongodb-ubuntu-2404#step-7-securing-mongodb

## Grafana

Manual Grafana Install

https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/

```java
# Import the GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add a repository for stable releases
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Updates the list of available packages
sudo apt-get update

# Installs the latest OSS release:
sudo apt-get install grafana
```

## InfluxDB

Add the GPG Key for InfluxDB, Download the GPG Key:

These instructions are specific for Ubuntu 24

https://docs.influxdata.com/influxdb/v2/install/?t=Linux

```java
# Clean up any existing keyring files and repository configurations to avoid conflicts
sudo rm -f /usr/share/keyrings/influxdb-archive-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/influxdb.list

# Ubuntu and Debian

# Add the InfluxData key to verify downloads and add the repository
curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key
echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum --check - && cat influxdata-archive.key \
| gpg --dearmor \
| tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| tee /etc/apt/sources.list.d/influxdata.list

# Install influxdb
# sudo apt-get update && sudo apt-get install influxdb2

# Update the package lists to apply the changes
sudo apt-get update

```

Install InfluxDB v2:

```java
sudo salt '*' state.apply influxdb.v2.install
```

Upgrade InfluxDB v2:

```java
sudo salt '*' state.apply influxdb.v2.upgrade
```

View the status

```java
sudo service influxdb status
```

Install InfluxDB v3:

```java
sh
sudo salt '*' state.apply influxdb.v3.install
```

Upgrade InfluxDB v3:

```java
sudo salt '*' state.apply influxdb.v3.upgrade
```

## Webserver apache2 and nginx

Install Apache2:

```java
sudo salt '*' state.apply webserver.apache2.install
```

Uninstall Apache2:

```java
sudo salt '*' state.apply webserver.apache2.uninstall
```

Upgrade Apache2:

```java
sudo salt '*' state.apply webserver.apache2.upgrade
```

Install Nginx:

```java
sudo salt '*' state.apply webserver.nginx.install
```

Uninstall Nginx:

```java
sudo salt '*' state.apply webserver.nginx.uninstall
```

Upgrade Nginx:

```java
sudo salt '*' state.apply webserver.nginx.upgrade
```

## Payload CMS

https://payloadcms.com/docs/getting-started/installation

https://payloadcms.com/docs/getting-started/what-is-payload

Create new Payload CMS app

https://www.npmjs.com/package/create-payload-app

```java

create-payload-app

  USAGE

      $ npx create-payload-app
      $ npx create-payload-app my-project
      $ npx create-payload-app -n my-project -t website

  OPTIONS

      -n     my-payload-app         Set project name
      -t     template_name          Choose specific template

        Available templates:

        blank                       Blank Template
        website                     Website Template
        ecommerce                   E-commerce Template
        plugin                      Template for creating a Payload plugin
        payload-demo                Payload demo site at https://demo.payloadcms.com
        payload-website             Payload website CMS at https://payloadcms.com

      --use-npm                     Use npm to install dependencies
      --use-yarn                    Use yarn to install dependencies
      --use-pnpm                    Use pnpm to install dependencies
      --no-deps                     Do not install any dependencies
      -h                            Show help
```

Next, install a Database Adapter. Payload requires a Database Adapter to establish a database connection. Payload works with all types of databases, but the most common are MongoDB and Postgres.

To install a Database Adapter, you can run one of the following commands:

To install the MongoDB Adapter, run:
```java
pnpm i @payloadcms/db-mongodb
```

To install the Postgres Adapter, run:

```java
pnpm i @payloadcms/db-postgres
```

## Postgresql

https://www.cherryservers.com/blog/install-postgresql-ubuntu

Manual Install

First download curl, ca-certificates, pip, venv, and libpq-dev

```java
sudo apt-get install curl ca-certificates python3-pip python3-venv libpq-dev -y
```

```java
curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc -fail  https://www.postgresql.org/media/keys/ACCC4CF8.asc
```

To determine the codename of your Ubuntu release type:

```java
lsb_release -cs
```

Create the sources list for the PostgreSQL package with the help of the nano editor.

```java
sudo nano /etc/apt/sources.list.d/pgdg.list
```

Write the source code as shown below.

```java
deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt  noble-pgdg main
```

Instead of noble, you should put the codename of your distribution which you found out via the lsb_release command. Write to the file with the help of Control O. Type Enter and then exit the nano text editor with Control X.

You can use ls to verify the pgdg.list has been added.

Step 2: Install PostgreSQL on Ubuntu 24.04 LTS

```java
sudo apt-get update

sudo apt-get install postgresql -y
```

View running status 

```java
systemctl status postgresql
```

Step 3: Log into PostgreSQL

PostgreSQL creates a default user named postgres. The postgres user is a superuser, which means that this role has all the privileges one can have inside the PostgreSQL DBMS.

To log into the database server as the user postgres type:

```java
sudo -u postgres psql
```

The superuser postgres doesn’t have a default password. Before going any further you should create one as without it your PostgreSQL database server may become an easy target for cybercriminals once you expose the DBMS to accept remote connections.

To create a password for the postgres user type the following command on the PostgeSQL’s console.

```java
\password postgres
```

To update the password for the postgres user from the PostgreSQL console type:

```java
ALTER USER postgres WITH PASSWORD ‘new_password_here’;
```

To exit the PostgreSQL console type:

```java
\q
# or
exit
```

Step 4: Configure PostgreSQL

Many more options to be set, see

https://www.cherryservers.com/blog/install-postgresql-ubuntu

## MinIO

Manual Install

```java
```

## Kafka

Manual Install

```java
```

## Python Application

Manual Install

```java
```

