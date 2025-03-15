fetch_supabase_secrets:
  cmd.run:
    - name: |
        sudo -u supabase_user sh -c \
        "vault kv get -field=POSTGRES_PASSWORD secret/data/supabase > /opt/supabase/.env && \
         vault kv get -field=GOTRUE_JWT_SECRET secret/data/supabase >> /opt/supabase/.env"
    - unless: test -f /opt/supabase/.env

create_supabase_directory:
  file.directory:
    - name: /opt/supabase
    - user: supabase_user
    - group: supabase_user
    - mode: 755

create_docker_compose_file:
  file.managed:
    - name: /opt/supabase/docker-compose.yml
    - source: salt://supabase/docker-compose.yml
    - user: supabase_user
    - group: supabase_user
    - mode: 644

start_supabase_services:
  cmd.run:
    - name: sudo -u supabase_user docker-compose up -d
    - cwd: /opt/supabase
    - require:
      - cmd: fetch_supabase_secrets
      - file: create_docker_compose_file
