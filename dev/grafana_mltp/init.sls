# /srv/salt/grafana-mltp/init.sls

# Install prerequisites
install_docker_prereqs:
  pkg.installed:
    - pkgs:
        - curl
        - ca-certificates
        - gnupg
        - lsb-release  # For Ubuntu; adjust for CentOS if needed

# Add Docker GPG key
add_docker_gpg_key:
  cmd.run:
    - name: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    - unless: test -f /usr/share/keyrings/docker-archive-keyring.gpg
    - require:
        - pkg: install_docker_prereqs

# Add Docker repository
add_docker_repo:
  cmd.run:
    - name: echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    - unless: test -f /etc/apt/sources.list.d/docker.list
    - require:
        - cmd: add_docker_gpg_key

# Install Docker
install_docker:
  pkg.installed:
    - pkgs:
        - docker-ce
        - docker-ce-cli
        - containerd.io
    - refresh: True
    - require:
        - cmd: add_docker_repo

# Ensure Docker service is running
docker_service:
  service.running:
    - name: docker
    - enable: True
    - require:
        - pkg: install_docker

# Install Docker Compose
install_docker_compose:
  cmd.run:
    - name: curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    - unless: test -f /usr/local/bin/docker-compose
    - require:
        - pkg: install_docker_prereqs
  file.managed:
    - name: /usr/local/bin/docker-compose
    - mode: 0755
    - require:
        - cmd: install_docker_compose