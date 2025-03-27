## MinIO

Manual Install

```java
sudo salt '*' state.apply minio.install saltenv=dev

sudo salt '*' state.apply minio.uninstall saltenv=dev

sudo salt '*' state.apply minio.upgrade saltenv=dev

sudo salt '*' state.apply minio.start saltenv=dev

sudo salt '*' state.apply minio.stop saltenv=dev
```

