# Include the install.sls states
include:
  - hashicorp_hcp.install

# Count the secrets in HCP Vault using API
count_hcp_secrets:
  cmd.run:
    - name: |
        curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
        --header "Authorization: Bearer $(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
        --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
        --data-urlencode "grant_type=client_credentials" \
        --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)" | jq '.secrets | length'
    - require:
      - pkg: install_dependencies
