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
- [ ] Webserver
    - [X] apache2
    - [X] nginx
    - [ ] Demo website
    - [ ] https certificate
- [ ] postgresql
    - [ ] Grafana Dashboard(s)
- [ ] supabase
    - [ ] Grafana Dashboard(s)
- [ ] mongoDB
    - [ ] Grafana Dashboard(s)
- [ ] kafka
    - [ ] Grafana Dashboard(s)
- [ ] k3s or MicroK8s
    - [ ] Grafana Dashboard(s)
- [X] influxDB
    - [ ] influxDB Grafana Dashboard(s)
- [ ] Python Application
    - [ ] CPU Memory Disk Processes Grafana Dashboard(s)
    - [ ] Distribute via apt package

## Backup hard drive

- [ ] rsync

### Other related repos for setups and installation

https://github.com/coding-to-music/saltstack-salt-in-10-minutes

https://github.com/coding-to-music/setup-linux-server-rsync-data-from-old-server

https://github.com/coding-to-music/install-virtualbox-on-digitalocean-or-contabo

https://github.com/coding-to-music/using-fail2ban-to-harden-linux-server

## MicroK8s

https://microk8s.io/?_gl=1*vqfb35*_gcl_au*MTU0NjY4NTgwMi4xNzM5ODIyNTg0

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

## Supabase

Manual Install

```java
```

## Postgresql

Manual Install

```java
```

## MongoDB

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

