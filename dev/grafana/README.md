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

Salt commands for Grafana

```java
sudo salt '*' state.apply grafana.install saltenv=dev

sudo salt '*' state.apply grafana.uninstall saltenv=dev

sudo salt '*' state.apply grafana.upgrade saltenv=dev

sudo salt '*' state.apply grafana.start saltenv=dev

sudo salt '*' state.apply grafana.stop saltenv=dev
```

