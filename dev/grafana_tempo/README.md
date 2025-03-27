## Grafana Tempo

https://grafana.com/docs/tempo/latest/setup/linux/

Manual Tempo Install


Salt commands for Tempo

```java
sudo salt '*' state.apply grafana_tempo.install saltenv=dev

sudo salt '*' state.apply grafana_tempo.uninstall saltenv=dev

sudo salt '*' state.apply grafana_tempo.upgrade saltenv=dev

sudo salt '*' state.apply grafana_tempo.start saltenv=dev

sudo salt '*' state.apply grafana_tempo.stop saltenv=dev
```

