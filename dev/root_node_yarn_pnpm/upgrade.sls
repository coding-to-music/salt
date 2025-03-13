nvm_profile:
  file.append:
    - name: /root/.bashrc
    - text: |
        export NVM_DIR="/root/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

nvm_source:
  cmd.run:
    - name: |
        source /root/.bashrc && export NVM_DIR="/root/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    - shell: /bin/bash
    - require:
      - file: nvm_profile

node_upgrade:
  cmd.run:
    - name: |
        source /root/.bashrc && export NVM_DIR="/root/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install 23 --reinstall-packages-from=default
    - require:
      - cmd: nvm_source

yarn_upgrade:
  cmd.run:
    - name: |
        source /root/.bashrc && export NVM_DIR="/root/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm update -g yarn
    - require:
      - cmd: node_upgrade

pnpm_upgrade:
  cmd.run:
    - name: |
        source /root/.bashrc && export NVM_DIR="/root/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm update -g pnpm
    - require:
      - cmd: yarn_upgrade

verify_upgrades:
  cmd.run:
    - name: |
        source /root/.bashrc && export NVM_DIR="/root/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && node -v && nvm current && npm -v && yarn -v && pnpm -v
    - require:
      - cmd: pnpm_upgrade
