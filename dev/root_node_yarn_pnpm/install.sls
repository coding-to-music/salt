nvm_install:
  cmd.run:
    - name: |
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    - unless: test -d "/root/.nvm"

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
      - cmd: nvm_install
      - file: nvm_profile

node_install:
  cmd.run:
    - name: |
        source /root/.bashrc && export NVM_DIR="/root/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install 23
    - require:
      - cmd: nvm_source

yarn_install:
  cmd.run:
    - name: |
        source /root/.bashrc && export NVM_DIR="/root/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm install -g yarn
    - require:
      - cmd: node_install

pnpm_install:
  cmd.run:
    - name: |
        source /root/.bashrc && export NVM_DIR="/root/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm install -g pnpm
    - require:
      - cmd: yarn_install

verify_installations:
  cmd.run:
    - name: |
        source /root/.bashrc && export NVM_DIR="/root/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && node -v && nvm current && npm -v && yarn -v && pnpm -v
    - require:
      - cmd: pnpm_install
