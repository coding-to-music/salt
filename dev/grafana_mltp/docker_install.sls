# /srv/salt/grafana-mltp/dev/docker_install.sls

# Install necessary dependencies
install_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - jq
      - software-properties-common

# Add the Docker GPG key
add_docker_gpg_key:
  cmd.run:
    - name: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    - unless: test -f /usr/share/keyrings/docker-archive-keyring.gpg
    - require:
      - pkg: install_dependencies

# Add the Docker repository
add_docker_repo:
  cmd.run:
    - name: echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
    - unless: test -f /etc/apt/sources.list.d/docker.list
    - require:
      - cmd: add_docker_gpg_key

# Update the apt package cache
update_apt_cache:
  cmd.run:
    - name: apt-get update
    - require:
      - cmd: add_docker_repo

# Install Docker packages
install_docker:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - require:
      - cmd: update_apt_cache

# Install the latest version of Docker Compose dynamically
install_docker_compose:
  cmd.run:
    - name: |
        LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
        curl -L "https://github.com/docker/compose/releases/download/${LATEST_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    - unless: test -f /usr/local/bin/docker-compose
    - require:
      - pkg: install_docker
      - pkg: install_dependencies

# Ensure Docker service is running
docker_service:
  service.running:
    - name: docker
    - enable: True
    - require:
        - pkg: install_docker