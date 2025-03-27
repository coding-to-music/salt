## Grafana Mimir

https://grafana.com/docs/mimir/latest/get-started/

Manual Mimir Install


Salt commands for Mimir

```java
sudo salt '*' state.apply grafana_mimir.install saltenv=dev

sudo salt '*' state.apply grafana_mimir.uninstall saltenv=dev

sudo salt '*' state.apply grafana_mimir.upgrade saltenv=dev

sudo salt '*' state.apply grafana_mimir.start saltenv=dev

sudo salt '*' state.apply grafana_mimir.stop saltenv=dev
```

