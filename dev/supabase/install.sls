supabase_repo:
  cmd.run:
    - name: |
        wget -qO- https://deb.nodesource.com/setup_14.x | sudo -E bash -
        wget -qO- https://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo tee /usr/share/keyrings/postgresql-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] https://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
        sudo apt-get update
    - unless: test -f /etc/apt/sources.list.d/pgdg.list

supabase_install:
  pkg.installed:
    - pkgs:
      - nodejs
      - npm
      - postgresql-13
      - postgresql-client-13
      - postgresql-contrib
      - postgresql-server-dev-13
      - build-essential
      - libssl-dev

supabase_cli_install:
  cmd.run:
    - name: |
        npm install -g supabase
    - unless: test -f /usr/local/bin/supabase

supabase_service:
  service.running:
    - name: postgresql
    - enable: True
    - watch:
      - pkg: supabase_install
