# Count the secrets in HCP Vault using the centralized .env
count_hcp_secrets:
  cmd.run:
    - name: |
        curl -s --location "$(cat /srv/salt/.env | grep HCP_SECRETS_URL | cut -d '=' -f2)" \
        --header "Authorization: Bearer $(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "client_id=$(cat /srv/salt/.env | grep HCP_CLIENT_ID | cut -d '=' -f2)" \
        --data-urlencode "client_secret=$(cat /srv/salt/.env | grep HCP_CLIENT_SECRET | cut -d '=' -f2)" \
        --data-urlencode "grant_type=client_credentials" \
        --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)" | jq '.data | length'
    - require:
      - pkg: install_dependencies
