nvm_install:
  cmd.run:
    - name: |
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    - unless: test -d "/root/.nvm"

nvm_source:
  cmd.run:
    - name: |
        . "/root/.nvm/nvm.sh"
    - unless: test -n "$NVM_DIR"

node_install:
  cmd.run:
    - name: |
        . "/root/.nvm/nvm.sh" && nvm install 23
    - require:
      - cmd: nvm_install
      - cmd: nvm_source

yarn_install:
  cmd.run:
    - name: |
        . "/root/.nvm/nvm.sh" && npm install -g yarn
    - require:
      - cmd: node_install

pnpm_install:
  cmd.run:
    - name: |
        . "/root/.nvm/nvm.sh" && npm install -g pnpm
    - require:
      - cmd: yarn_install

verify_installations:
  cmd.run:
    - name: |
        . "/root/.nvm/nvm.sh" && node -v && nvm current && npm -v && yarn -v && pnpm -v
    - require:
      - cmd: pnpm_install
