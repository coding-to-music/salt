# Ensure working directory exists (for consistency with update.sls)
grafana_mltp_dir:
  file.directory:
    - name: /opt/grafana-mltp
    - user: root
    - group: root
    - mode: 755

# Include Docker service dependency (assuming it's defined in docker_install.sls)
include:
  - grafana_mltp.docker_install

# Stop all Docker Compose services
stop_docker_compose:
  cmd.run:
    - name: /usr/local/bin/docker-compose -f /opt/grafana-mltp/docker-compose.yml down
    - cwd: /opt/grafana-mltp
    - require:
        - file: grafana_mltp_dir
        - service: docker_service
    - onlyif: 
        - test -f /opt/grafana-mltp/docker-compose.yml  # Only run if the file exists
        - /usr/local/bin/docker-compose -f /opt/grafana-mltp/docker-compose.yml ps -q | grep -q .  # Only run if containers are running

# Restart all Docker Compose services (stop and start)
restart_docker_compose:
  cmd.run:
    - name: /usr/local/bin/docker-compose -f /opt/grafana-mltp/docker-compose.yml restart
    - cwd: /opt/grafana-mltp
    - require:
        - file: grafana_mltp_dir
        - service: docker_service
    - onlyif: 
        - test -f /opt/grafana-mltp/docker-compose.yml  # Only run if the file exists
        - /usr/local/bin/docker-compose -f /opt/grafana-mltp/docker-compose.yml ps -q | grep -q .  # Only run if containers are running
        