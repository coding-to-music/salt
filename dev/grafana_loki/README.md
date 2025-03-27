## Grafana Loki

https://grafana.com/docs/loki/latest/setup/install/local/

Manual Loki Install

```java
apt-get update
apt-get install loki promtail
```

Salt commands for Loki

```java
sudo salt '*' state.apply grafana_loki.install saltenv=dev

sudo salt '*' state.apply grafana_loki.uninstall saltenv=dev

sudo salt '*' state.apply grafana_loki.upgrade saltenv=dev

sudo salt '*' state.apply grafana_loki.start saltenv=dev

sudo salt '*' state.apply grafana_loki.stop saltenv=dev
```

