## Kafka

Manual Install

```java
```

Salt commands for Kafka

```java
sudo salt '*' state.apply kafka.install saltenv=dev

sudo salt '*' state.apply kafka.uninstall saltenv=dev

sudo salt '*' state.apply kafka.upgrade saltenv=dev

sudo salt '*' state.apply kafka.start saltenv=dev

sudo salt '*' state.apply kafka.stop saltenv=dev
```

Validate

```java
systemctl status confluent-server
```

