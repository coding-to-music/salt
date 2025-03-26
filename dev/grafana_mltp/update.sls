# /srv/salt/grafana-mltp/update.sls

# Ensure working directory exists
grafana_mltp_dir:
  file.directory:
    - name: /opt/grafana-mltp
    - user: root
    - group: root
    - mode: 755

# Fetch the latest docker-compose.yml from GitHub
fetch_docker_compose:
  cmd.run:
    - name: curl -s -L https://raw.githubusercontent.com/grafana/intro-to-mltp/main/docker-compose.yml -o /opt/grafana-mltp/docker-compose.yml
    - creates: /opt/grafana-mltp/docker-compose.yml
    - require:
        - file: grafana_mltp_dir

# Pull the latest Docker images
pull_docker_images:
  cmd.run:
    - name: /usr/local/bin/docker-compose -f /opt/grafana-mltp/docker-compose.yml pull
    - cwd: /opt/grafana-mltp
    - require:
        - cmd: fetch_docker_compose
        - service: docker_service

# Start or update Docker Compose services
run_docker_compose:
  cmd.run:
    - name: /usr/local/bin/docker-compose -f /opt/grafana-mltp/docker-compose.yml up -d
    - cwd: /opt/grafana-mltp
    - require:
        - cmd: pull_docker_images
    - onchanges:
        - cmd: fetch_docker_compose
        - cmd: pull_docker_images