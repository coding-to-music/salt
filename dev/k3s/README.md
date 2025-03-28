## k3s

https://docs.k3s.io/installation

https://computingforgeeks.com/installing-k3s-on-ubuntu-noble-numbat/

https://docs.k3s.io/installation/requirements?os=debian

Manual Install

```java
```

Salt commands for k3s

```java
sudo salt '*' state.apply k3s.install saltenv=dev

sudo salt '*' state.apply k3s.uninstall saltenv=dev

sudo salt '*' state.apply k3s.upgrade saltenv=dev

sudo salt '*' state.apply k3s.start saltenv=dev

sudo salt '*' state.apply k3s.stop saltenv=dev
```


