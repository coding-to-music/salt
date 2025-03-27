## Grafana MLTP - Metrics, Logs, Traces and Profiles

https://grafana.com/docs/loki/latest/setup/install/local/

Manual Install

https://github.com/grafana/intro-to-mltp


Salt commands for Grafana mltp

- init.sls: Installs dependencies and sets up the initial environment.
- update.sls: Fetches the latest files and updates the running containers.
- files/: Optional directory for Jinja-templated files (if customization is needed).

```java
# do these first once just to setup supabase_user in linux and install docker and docker-compose
sudo salt '*' state.apply grafana_mltp.docker_install saltenv=dev

# This will download the grafana_mltp docker-compose files from github and yaml files and start them
sudo salt '*' state.apply grafana_mltp.update saltenv=dev


# This init may not be needed since it is all docker
sudo salt '*' state.apply grafana_mltp.init saltenv=dev

# These need to be created
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



