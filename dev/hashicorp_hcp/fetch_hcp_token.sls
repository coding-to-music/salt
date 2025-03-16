# Fetch the HCP API token
fetch_hcp_token:
  cmd.run:
    - name: |
        curl -s -X POST https://auth.cloud.hashicorp.com/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{
          "client_id": "your-client-id",
          "client_secret": "your-client-secret"
        }' > /tmp/hcp_token.json
    - require:
      - pkg: install_dependencies

# Extract and store the token from the JSON response
store_token_in_env:
  cmd.run:
    - name: |
        jq -r '.access_token' /tmp/hcp_token.json > /srv/salt/hashicorp_hcp/.env
    - require:
      - cmd: fetch_hcp_token
