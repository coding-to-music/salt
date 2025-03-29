# Include the install.sls states (e.g., for Docker installation)
include:
  - grafana_mltp.docker_install

# Ensure working directory exists
grafana_mltp_dir:
  file.directory:
    - name: /opt/grafana-mltp
    - user: root
    - group: root
    - mode: 755

# Create subdirectories for dashboards and config
grafana_mltp_dashboards_dir:
  file.directory:
    - name: /opt/grafana-mltp/dashboards
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: grafana_mltp_dir

grafana_mltp_config_dir:
  file.directory:
    - name: /opt/grafana-mltp/config
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: grafana_mltp_dir

# Fetch the latest docker-compose.yml from GitHub
fetch_docker_compose:
  cmd.run:
    - name: curl -s -L https://raw.githubusercontent.com/grafana/intro-to-mltp/main/docker-compose.yml -o /opt/grafana-mltp/docker-compose.yml
    - creates: /opt/grafana-mltp/docker-compose.yml
    - require:
        - file: grafana_mltp_dir

# Fetch dashboard files
fetch_grafana_dashboard:
  cmd.run:
    - name: curl -s -L https://raw.githubusercontent.com/grafana/intro-to-mltp/main/dashboards/grafana.json -o /opt/grafana-mltp/dashboards/grafana.json
    - creates: /opt/grafana-mltp/dashboards/grafana.json
    - require:
        - file: grafana_mltp_dashboards_dir

# Fetch config files (repeat for each file)
fetch_mimir_config:
  cmd.run:
    - name: curl -s -L https://raw.githubusercontent.com/grafana/intro-to-mltp/main/config/mimir.yaml -o /opt/grafana-mltp/config/mimir.yaml
    - creates: /opt/grafana-mltp/config/mimir.yaml
    - require:
        - file: grafana_mltp_config_dir

fetch_loki_config:
  cmd.run:
    - name: curl -s -L https://raw.githubusercontent.com/grafana/intro-to-mltp/main/config/loki.yaml -o /opt/grafana-mltp/config/loki.yaml
    - creates: /opt/grafana-mltp/config/loki.yaml
    - require:
        - file: grafana_mltp_config_dir

fetch_tempo_config:
  cmd.run:
    - name: curl -s -L https://raw.githubusercontent.com/grafana/intro-to-mltp/main/config/tempo.yaml -o /opt/grafana-mltp/config/tempo.yaml
    - creates: /opt/grafana-mltp/config/tempo.yaml
    - require:
        - file: grafana_mltp_config_dir

fetch_alloy_config:
  cmd.run:
    - name: curl -s -L https://raw.githubusercontent.com/grafana/intro-to-mltp/main/config/alloy-config.alloy -o /opt/grafana-mltp/config/alloy-config.alloy
    - creates: /opt/grafana-mltp/config/alloy-config.alloy
    - require:
        - file: grafana_mltp_config_dir

# Pull the latest Docker images
pull_docker_images:
  cmd.run:
    - name: /usr/local/bin/docker-compose -f /opt/grafana-mltp/docker-compose.yml pull
    - cwd: /opt/grafana-mltp
    - require:
        - cmd: fetch_docker_compose
        - cmd: fetch_grafana_dashboard
        - cmd: fetch_mimir_config
        - cmd: fetch_loki_config
        - cmd: fetch_tempo_config
        - cmd: fetch_alloy_config
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
        - cmd: fetch_grafana_dashboard
        - cmd: fetch_mimir_config
        - cmd: fetch_loki_config
        - cmd: fetch_tempo_config
        - cmd: fetch_alloy_config
        - cmd: pull_docker_images