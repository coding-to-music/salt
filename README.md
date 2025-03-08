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

## Grafana

Manual Grafana Install

```java
# Import the GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null


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

