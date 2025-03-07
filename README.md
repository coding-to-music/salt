# salt

## 🚀 Salt Stack formulas for salt-master and salt-minion 🚀

https://github.com/coding-to-music/salt

From / By

## Environment variables

```java

```

## GitHub

```java
git init
git add .
git remote remove origin
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:coding-to-music/salt.git
git push -u origin main
```

## InfluxDB

Install InfluxDB v2:

```java
sudo salt '*' state.apply influxdb.v2.install
```

Upgrade InfluxDB v2:

```java
sudo salt '*' state.apply influxdb.v2.upgrade
```

Install InfluxDB v3:

```java
sh
sudo salt '*' state.apply influxdb.v3.install
```

Upgrade InfluxDB v3:

```java
sudo salt '*' state.apply influxdb.v3.upgrade
```

## Webserver apache2 and nginx

Install Apache2:

```java
sudo salt '*' state.apply webserver.apache2.install
```

Uninstall Apache2:

```java
sudo salt '*' state.apply webserver.apache2.uninstall
```

Upgrade Apache2:

```java
sudo salt '*' state.apply webserver.apache2.upgrade
```

Install Nginx:

```java
sudo salt '*' state.apply webserver.nginx.install
```

Uninstall Nginx:

```java
sudo salt '*' state.apply webserver.nginx.uninstall
```

Upgrade Nginx:

```java
sudo salt '*' state.apply webserver.nginx.upgrade
```

