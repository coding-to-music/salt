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

### Other related repos for setups and installation

https://github.com/coding-to-music/saltstack-salt-in-10-minutes

https://github.com/coding-to-music/setup-linux-server-rsync-data-from-old-server

https://github.com/coding-to-music/install-virtualbox-on-digitalocean-or-contabo

https://github.com/coding-to-music/using-fail2ban-to-harden-linux-server


## Useful commands

```java
sudo salt-run fileserver.update
sudo salt-run fileserver.file_list
sudo salt-run fileserver.file_list | grep '.sls'

sudo salt-run fileserver.file_list | grep '.sls' | grep java

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
### Set the salt-master config

back up existing salt master config file

```java
mv /etc/salt/master /etc/salt/master.$(date +%Y-%m-%d_%H-%M-%S)
```

Edit the salt master config file

```java
sudo nano /etc/salt/master
```

Use this content for `/etc/salt/master`

```java
user: salt
interface: 0.0.0.0
log_level: warning
log_file: /var/log/salt/master
pki_dir: /etc/salt/pki/master
cachedir: /var/cache/salt/master
auto_accept: False
fileserver_backend:
  - roots
file_roots:
  base:
     - /srv/salt
  dev:
    - /srv/salt/dev
```

Restart the salt-master

```java
sudo systemctl restart salt-master
sudo systemctl status salt-master
```

### Let the salt-minion know the address of the salt-master

Check what salt resolves to

```java
nslookup salt
```

Expected example Output

```java
Server:         127.0.0.53
Address:        127.0.0.53#53

salt    canonical name = localhost.
Name:   localhost
Address: 127.0.0.1
Name:   localhost
Address: ::1
```


```java
sudo nano /etc/hosts
```

If the master and minion are on the same server

Set this existing line to:

```java
127.0.0.1 localhost salt
```

If the minion is on a different server from the master, add a new line

```java
192.168.1.100 salt
```

Restart the minion

```java
sudo systemctl restart salt-minion
sudo systemctl status salt-minion
```

This forces your minion to resolve "salt" to the correct IP address of your master.

### accept keys so the master and minions see each other

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

- [X] set hostname
- [X] set time zone to NYC
- [ ] remote mount a drive
- [ ] setup drive rsync

### Users

- [X] install ssh keys
- [ ] disable root login
- [X] create user for myself
- [X] .bash_aliases for myself
- [X] sudo for myself
- [X] create user docker
- [X] create user grafana

### cli Software

- [X] github git
- [X] gh github login
- [ ] vercel
- [ ] cloudflare

### systemctl processes

- [X] node-exporter
- [X] grafana alloy
- [ ] ufw firewall
- [X] docker
- [ ] fail2ban

### environment software

- [X] nvm
- [X] node
- [X] yarn
- [X] pnpm
- [ ] deno
- [ ] pyenv
- [X] python3

### Salt-Stack
- [X] Pillars
- [X] Grains
- [X] Hashicorp Vault


### databases & more

- [X] Grafana 
    - [ ] Dashboards
    - [ ] Grafana Auth
    - [ ] Data Sources
    - [ ] Users
- [X] Grafana Loki
- [X] Grafana Tempo
- [X] Grafana Mimir
- [X] Grafana k6
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
- [X] postgresql
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
- [X] k3s 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [X] Docker 
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

## Salt Terminology - Grains vs Pillars

### Grains

What Are Grains?

- Grains provide static, system-specific information about a Salt minion.
- Examples include OS version, architecture, hostname, IP address, and custom-defined variables (like the hostname you set earlier).

Purpose:

- Grains are useful for categorizing and targeting minions during state execution.
- You can define custom grains to store additional, fixed metadata (e.g., server roles, locations).

How Grains Work:

- They are collected directly from the minion, usually at startup.
- Stored locally on the minion.
- Grains data is accessible throughout a Salt run and doesn't require querying the Salt master.

Examples:

- Default grains: OS, kernel, hostname.
- Custom grains: hostname: server1.

Use Case:

- Target minions based on specific characteristics, e.g., applying states only to Ubuntu servers:

```java
sudo salt -G 'os:Ubuntu' state.apply
```

Key Properties:

- Static or rarely changing.
- Stored on minions (/etc/salt/grains).

### Pillars

What Are Pillars?

- Pillars provide secure, hierarchical data that is assigned from the Salt master to minions.
- Designed for sensitive information, like API keys, passwords, and configurations that shouldn't be hardcoded into states.

Purpose:

- Pillars enable dynamic, customizable data for minions.
- This data is defined and managed centrally on the Salt master.

How Pillars Work:

- Pillars are configured in pillar files on the master (/srv/pillar).
- You can assign data to specific minions or groups of minions via the pillar top file (/srv/pillar/top.sls).
- The master sends pillar data securely to minions during execution.

Examples:

- Storing a database password in a pillar:

```java
db_password: "securepassword123"
```

- Accessing the pillar in a state:

```java
{% set db_pass = salt['pillar.get']('db_password') %}
```

Use Case:

- Distribute secrets or configurations securely, e.g., providing an API key to a specific server.

Key Properties:

- Dynamic and assigned per minion.
- Stored securely on the master.

Comparison
| Feature          | Grains                         | Pillars                              |
|------------------|--------------------------------|--------------------------------------|
| **Purpose**      | Static, system metadata       | Dynamic, secure configuration data   |
| **Location**     | Stored on the minion          | Stored on the master                 |
| **Use**          | Targeting minions and metadata | Distributing secrets/configurations  |
| **Example**      | OS, hostname, IP address      | API keys, passwords, custom configs  |
| **Accessibility**| Automatically available to minion | Assigned securely from the master   |

When to Use Each

- Grains: Use grains for static data that describes the minion itself, such as its location, role, or operating system.  
- Pillars: Use pillars for dynamic, sensitive, or application-specific data that you want to securely distribute from the master.

