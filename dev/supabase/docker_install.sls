install_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - software-properties-common

add_docker_gpg_key:
  cmd.run:
    - name: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    - unless: test -f /usr/share/keyrings/docker-archive-keyring.gpg

add_docker_repo:
  cmd.run:
    - name: echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
    - unless: test -f /etc/apt/sources.list.d/docker.list
    - require:
      - cmd: add_docker_gpg_key

update_apt_cache:
  cmd.run:
    - name: apt-get update
    - require:
      - cmd: add_docker_repo

install_docker:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - require:
      - cmd: update_apt_cache

install_docker_compose:
  cmd.run:
    - name: |
        curl -L "https://github.com/docker/compose/releases/download/2.16.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    - unless: test -f /usr/local/bin/docker-compose
    - require:
      - pkg: install_docker
