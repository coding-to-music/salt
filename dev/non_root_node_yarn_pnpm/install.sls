{% set user = "your_non_root_username" %}

nvm_install:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
    - unless: test -d "/home/{{ user }}/.nvm"

nvm_source:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh"
    - unless: test -n "$NVM_DIR"

node_install:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh && nvm install 23"
    - require:
      - cmd: nvm_install
      - cmd: nvm_source

yarn_install:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh && npm install -g yarn"
    - require:
      - cmd: node_install

pnpm_install:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh && npm install -g pnpm"
    - require:
      - cmd: yarn_install

verify_installations:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh && node -v && nvm current && npm -v && yarn -v && pnpm -v"
    - require:
      - cmd: pnpm_install
