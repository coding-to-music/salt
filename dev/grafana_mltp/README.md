## Grafana MLTP - Metrics, Logs, Traces and Profiles

https://grafana.com/docs/loki/latest/setup/install/local/

Manual Install

https://github.com/grafana/intro-to-mltp

![Introduction To MLTP Architecture Diagram](images/Introduction%20to%20MLTP%20Arch%20Diagram.png)

Salt commands for Grafana mltp

- init.sls: Installs dependencies and sets up the initial environment.
- update.sls: Fetches the latest files and updates the running containers.
- files/: Optional directory for Jinja-templated files (if customization is needed).

```java
# do these first once just to setup supabase_user in linux and install docker and docker-compose
sudo salt '*' state.apply grafana_mltp.docker_install saltenv=dev

# This will download the grafana_mltp docker-compose files from github and yaml files and start them
sudo salt '*' state.apply grafana_mltp.update saltenv=dev
```

Needed to do this:

```java
sudo rm -rf /opt/grafana-mltp/alloy/config.alloy
sudo touch /opt/grafana-mltp/alloy/config.alloy
```

```java
# run again
sudo salt '*' state.apply grafana_mltp.update saltenv=dev
```

Got Port conflict the docker compose wants to use port 4317 but the server itself is already running alloy and using port 4317

```java
sudo lsof -i :4317
```

Output

```java
COMMAND PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
alloy   829 alloy   11u  IPv6  12737      0t0  TCP *:4317 (LISTEN)
```

Next step is to have the server alloy use a different port

Was able to fix this by modifying `/etc/alloy/config.alloy`

```java
cat /etc/alloy/config.alloy | grep 43
// note the otlp_receiver default ports grpc=4317 and http=4318 are instead 4327 and 4328 
```

```java
# run again
sudo salt '*' state.apply grafana_mltp.update saltenv=dev
```

Got error port 80 was already in use

```java
Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint grafana-intro-to-mltp-mythical-server-1 (6ea05ecad0639f8b8015a4b973e857a83bb2396526432387a890147fe76909c5): failed to bind host port for 0.0.0.0:80:192.16.0.5:80/tcp: address already in use
```

salt '*' cmd.run 'ss -tuln | grep :80'

```java
    tcp   LISTEN 0      511                *:80               *:*
```

salt '*' cmd.run 'docker ps -a --format "{{.Names}} {{.Ports}}"'

```java
    grafana-intro-to-mltp-beyla-requester-1 
    grafana-intro-to-mltp-beyla-recorder-1 
    grafana-intro-to-mltp-mythical-requester-1 
    grafana-intro-to-mltp-beyla-server-1 
    grafana-intro-to-mltp-mythical-recorder-1 0.0.0.0:4002->4002/tcp, [::]:4002->4002/tcp
    grafana-intro-to-mltp-mythical-server-1 
    grafana-intro-to-mltp-alloy-1 0.0.0.0:4317-4318->4317-4318/tcp, [::]:4317-4318->4317-4318/tcp, 0.0.0.0:6832->6832/tcp, [::]:6832->6832/tcp, 0.0.0.0:12348->12348/tcp, [::]:12348->12348/tcp, 0.0.0.0:55679->55679/tcp, [::]:55679->55679/tcp, 0.0.0.0:12347->12345/tcp, [::]:12347->12345/tcp
    grafana-intro-to-mltp-k6-1 
    grafana-intro-to-mltp-mythical-queue-1 4369/tcp, 5671/tcp, 0.0.0.0:5672->5672/tcp, [::]:5672->5672/tcp, 15671/tcp, 15691-15692/tcp, 25672/tcp, 0.0.0.0:15672->15672/tcp, [::]:15672->15672/tcp
    grafana-intro-to-mltp-pyroscope-1 0.0.0.0:4040->4040/tcp, [::]:4040->4040/tcp
    grafana-intro-to-mltp-grafana-1 0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    grafana-intro-to-mltp-mimir-1 
    grafana-intro-to-mltp-loki-1 
    grafana-intro-to-mltp-tempo-1 
    grafana-intro-to-mltp-mythical-database-1 0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
```

Needed to remove webserver apache2

```java
sudo salt '*' state.apply webserver.apache2.uninstall saltenv=dev
```

```java
# run again
sudo salt '*' state.apply grafana_mltp.update saltenv=dev
```

Running now

```java
                   Container grafana-intro-to-mltp-mimir-1  Created
                   Container grafana-intro-to-mltp-mythical-queue-1  Running
                   Container grafana-intro-to-mltp-grafana-1  Running
                   Container grafana-intro-to-mltp-tempo-1  Created
                   Container grafana-intro-to-mltp-mythical-recorder-1  Running
                   Container grafana-intro-to-mltp-mythical-database-1  Running
                   Container grafana-intro-to-mltp-pyroscope-1  Running
                   Container grafana-intro-to-mltp-loki-1  Created
                   Container grafana-intro-to-mltp-beyla-recorder-1  Running
                   Container grafana-intro-to-mltp-alloy-1  Running
                   Container grafana-intro-to-mltp-mimir-1  Starting
                   Container grafana-intro-to-mltp-tempo-1  Starting
                   Container grafana-intro-to-mltp-loki-1  Starting
                   Container grafana-intro-to-mltp-mythical-queue-1  Waiting
                   Container grafana-intro-to-mltp-k6-1  Starting
                   Container grafana-intro-to-mltp-mythical-server-1  Starting
                   Container grafana-intro-to-mltp-k6-1  Started
                   Container grafana-intro-to-mltp-loki-1  Started
                   Container grafana-intro-to-mltp-mimir-1  Started
                   Container grafana-intro-to-mltp-mythical-server-1  Started
                   Container grafana-intro-to-mltp-mythical-queue-1  Waiting
                   Container grafana-intro-to-mltp-beyla-server-1  Starting
                   Container grafana-intro-to-mltp-mythical-queue-1  Healthy
                   Container grafana-intro-to-mltp-tempo-1  Started
                   Container grafana-intro-to-mltp-beyla-server-1  Started
                   Container grafana-intro-to-mltp-mythical-queue-1  Healthy
                   Container grafana-intro-to-mltp-mythical-requester-1  Starting
                   Container grafana-intro-to-mltp-mythical-requester-1  Started
                   Container grafana-intro-to-mltp-beyla-requester-1  Starting
                   Container grafana-intro-to-mltp-beyla-requester-1  Started
```


```java
salt '*' state.apply grafana-mltp.dev.control stop_docker_compose
```

# These need to be created

```java
sudo salt '*' state.apply grafana_mltp.install saltenv=dev

sudo salt '*' state.apply grafana_mltp.uninstall saltenv=dev

sudo salt '*' state.apply grafana_mltp.upgrade saltenv=dev

sudo salt '*' state.apply grafana_mltp.start saltenv=dev

sudo salt '*' state.apply grafana_mltp.stop saltenv=dev
```

### Verification

```java
sudo systemctl status salt-master
sudo systemctl status salt-minion

sudo systemctl restart salt-master
sudo systemctl restart salt-minion
```

Check that containers are running:

```java
salt 'your-minion-id' cmd.run 'docker ps'
```

Check the various files are created in the right locations

```java
ls -lat /opt/grafana-mltp

ls -lat /opt/grafana-mltp/docker-compose.yml

cat /opt/grafana-mltp/docker-compose.yml
```

### Customization (Optional)

If you need to modify the docker-compose.yml (e.g., change ports or environment variables), you can:

Use a Jinja Template:

Create /srv/salt/grafana-mltp/files/docker-compose.yml.jinja and fetch the raw file as a base, then customize it. For example:

```java
# /srv/salt/grafana-mltp/update.sls (modified snippet)
fetch_docker_compose_base:
  cmd.run:
    - name: curl -s -L https://raw.githubusercontent.com/grafana/intro-to-mltp/main/docker-compose.yml -o /tmp/docker-compose.yml.base
    - require:
        - file: grafana_mltp_dir

render_docker_compose:
  file.managed:
    - name: /opt/grafana-mltp/docker-compose.yml
    - source: salt://grafana-mltp/files/docker-compose.yml.jinja
    - template: jinja
    - context:
        base_content: {{ salt['cmd.run']('cat /tmp/docker-compose.yml.base') | yaml_encode }}
    - require:
        - cmd: fetch_docker_compose_base
```

In docker-compose.yml.jinja, you could append or modify sections:

```java
{{ base_content }}

# Add custom overrides here if needed
```

Pillar Data: Use Salt pillar to pass variables (e.g., `pillar['grafana_mltp']['port']`) for dynamic configuration.


### Automate Updates

To keep the environment updated, you can:

Schedule the Update State: Use Salt’s scheduler to run update.sls periodically.

Add this to your minion’s config (/etc/salt/minion or via pillar):

```java
schedule:
  update_grafana_mltp:
    function: state.apply
    args:
      - grafana-mltp.update
    minutes: 60  # Runs hourly; adjust as needed
```

Restart the minion:

```java
salt 'your-minion-id' service.restart salt-minion
```

Highstate Integration: Include both states in a top file (/srv/salt/top.sls):

```java
base:
  'your-minion-id':
    - grafana-mltp
    - grafana-mltp.update
```

Apply with:

```java
salt 'your-minion-id' state.highstate
```



