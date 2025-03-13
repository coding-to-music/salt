supabase_upgrade:
  pkg.latest:
    - pkgs:
      - nodejs
      - npm
      - postgresql-13
      - postgresql-client-13
      - postgresql-contrib
      - postgresql-server-dev-13
    - refresh: True

supabase_cli_upgrade:
  cmd.run:
    - name: |
        npm update -g supabase
    - require:
      - pkg: supabase_upgrade

supabase_service_restart:
  service.running:
    - name: postgresql
    - enable: True
    - watch:
      - pkg: supabase_upgrade
