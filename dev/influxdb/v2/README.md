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

Salt commands for InfluxDB V2

```java
sudo salt '*' state.apply influxdb.v2.install saltenv=dev

sudo salt '*' state.apply influxdb.v2.upgrade saltenv=dev

sudo service influxdb status
```

Salt commands for InfluxDB V3

```java
sudo salt '*' state.apply influxdb.v3.install saltenv=dev

sudo salt '*' state.apply influxdb.v3.upgrade saltenv=dev

sudo service influxdb status
```

