supabase_uninstall:
  pkg.removed:
    - pkgs:
      - nodejs
      - postgresql-13
      - postgresql-client-13
      - postgresql-contrib
      - postgresql-server-dev-13

supabase_cli_uninstall:
  cmd.run:
    - name: |
        npm uninstall -g supabase
    - onlyif: test -f /usr/local/bin/supabase

supabase_cleanup:
  file.absent:
    - names:
      - /etc/apt/sources.list.d/pgdg.list
      - /var/lib/postgresql/13
      - /usr/local/bin/supabase
