## Grafana K6

https://grafana.com/docs/k6/latest/set-up/install-k6/#linux

Manual K6 Install

```java
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

Runs as an executable when you want to load test, does not run as a service, thus there is no start and stop sls files

Salt commands for K6

```java
sudo salt '*' state.apply grafana_k6.install saltenv=dev

sudo salt '*' state.apply grafana_k6.uninstall saltenv=dev

sudo salt '*' state.apply grafana_k6.upgrade saltenv=dev
```

