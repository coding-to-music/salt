{% set user = "your_non_root_username" %}

nvm_source:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh"
    - unless: test -n "$NVM_DIR"

node_upgrade:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh && nvm install 23 --reinstall-packages-from=default"
    - require:
      - cmd: nvm_source

yarn_upgrade:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh && npm update -g yarn"
    - require:
      - cmd: node_upgrade

pnpm_upgrade:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh && npm update -g pnpm"
    - require:
      - cmd: yarn_upgrade

verify_upgrades:
  cmd.run:
    - name: |
        sudo -u {{ user }} -H sh -c ". /home/{{ user }}/.nvm/nvm.sh && node -v && nvm current && npm -v && yarn -v && pnpm -v"
    - require:
      - cmd: pnpm_upgrade
