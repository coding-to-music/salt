# Fetch secrets from HCP API and store them in .env
fetch_supabase_secrets:
  cmd.run:
    - name: |
        sudo -u supabase_user sh -c '
        echo "POSTGRES_PASSWORD=$(curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
          --header "Authorization: Bearer $(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
          --header "Content-Type: application/x-www-form-urlencoded" \
          --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "grant_type=client_credentials" \
          --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)" | jq -r ".secrets.POSTGRES_PASSWORD")" > /opt/supabase/.env &&
        echo "GOTRUE_JWT_SECRET=$(curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
          --header "Authorization: Bearer $(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
          --header "Content-Type: application/x-www-form-urlencoded" \
          --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "grant_type=client_credentials" \
          --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)" | jq -r ".secrets.GOTRUE_JWT_SECRET")" >> /opt/supabase/.env
        '
    - unless: test -f /opt/supabase/.env

# Create the Supabase directory
create_supabase_directory:
  file.directory:
    - name: /opt/supabase
    - user: supabase_user
    - group: supabase_user
    - mode: 755

# Deploy the Docker Compose file
create_docker_compose_file:
  file.managed:
    - name: /opt/supabase/docker-compose.yml
    - source: salt://supabase/docker-compose.yml
    - user: supabase_user
    - group: supabase_user
    - mode: 644

# Start Supabase services using Docker Compose
start_supabase_services:
  cmd.run:
    - name: sudo -u supabase_user docker-compose up -d
    - cwd: /opt/supabase
    - require:
      - cmd: fetch_supabase_secrets
      - file: create_docker_compose_file
