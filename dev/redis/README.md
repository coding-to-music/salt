## Redis

https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/

Manual Install

```java
sudo apt-get install lsb-release curl gpg
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install redis
```

Redis will start automatically, and it should restart at boot time. If Redis doesn't start across reboots, you may need to manually enable it:

```java
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

Connect to Redis
Once Redis is running, you can test it by running redis-cli:

redis-cli
Test the connection with the ping command:

127.0.0.1:6379> ping
PONG

https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/#install-redis-properly

https://redis.io/docs/latest/develop/tools/cli/

https://redis.io/docs/latest/develop/clients/

https://redis.io/docs/latest/develop/tools/insight/

https://redis.io/docs/latest/operate/redisinsight/install/

Salt commands for Redis

```java
sudo salt '*' state.apply redis.install saltenv=dev

sudo salt '*' state.apply redis.uninstall saltenv=dev

sudo salt '*' state.apply redis.upgrade saltenv=dev

sudo salt '*' state.apply redis.start saltenv=dev

sudo salt '*' state.apply redis.stop saltenv=dev
```

