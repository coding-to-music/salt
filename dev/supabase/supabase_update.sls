stop_supabase_services:
  cmd.run:
    - name: docker-compose down
    - cwd: /opt/supabase
    - require:
      - file: /opt/supabase/docker-compose.yml

pull_latest_images:
  cmd.run:
    - name: docker-compose pull
    - cwd: /opt/supabase
    - require:
      - cmd: stop_supabase_services

start_updated_services:
  cmd.run:
    - name: docker-compose up -d
    - cwd: /opt/supabase
    - require:
      - cmd: pull_latest_images
