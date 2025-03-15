fetch_supabase_secrets:
  cmd.run:
    - name: |
        echo "POSTGRES_PASSWORD=$(vault kv get -field=POSTGRES_PASSWORD secret/data/supabase)" > /opt/supabase/.env
        echo "GOTRUE_JWT_SECRET=$(vault kv get -field=GOTRUE_JWT_SECRET secret/data/supabase)" >> /opt/supabase/.env
    - unless: test -f /opt/supabase/.env

create_supabase_directory:
  file.directory:
    - name: /opt/supabase
    - user: root
    - group: root
    - mode: 755

create_docker_compose_file:
  file.managed:
    - name: /opt/supabase/docker-compose.yml
    - source: salt://supabase/docker-compose.yml
    - user: root
    - group: root
    - mode: 644
    - template: jinja

start_supabase_services:
  cmd.run:
    - name: docker-compose up -d
    - cwd: /opt/supabase
    - require:
      - cmd: fetch_supabase_secrets
      - file: create_docker_compose_file
