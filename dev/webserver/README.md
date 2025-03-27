## Webserver apache2 and nginx

Salt commands for Apache2:

```java
sudo salt '*' state.apply webserver.apache2.install saltenv=dev

sudo salt '*' state.apply webserver.apache2.uninstall saltenv=dev

sudo salt '*' state.apply webserver.apache2.upgrade saltenv=dev
```

Salt commands for Nginx:

```java
sudo salt '*' state.apply webserver.nginx.install saltenv=dev

sudo salt '*' state.apply webserver.nginx.uninstall saltenv=dev

sudo salt '*' state.apply webserver.nginx.upgrade saltenv=dev
```

