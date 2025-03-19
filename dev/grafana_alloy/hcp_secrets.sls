# Fetch secrets from HCP Vault and write them to /etc/default/alloy
fetch_hcp_secrets_and_set_env:
  cmd.run:
    - name: |
        # Fetch HCP API Token
        HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
          --header "Content-Type: application/x-www-form-urlencoded" \
          --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "grant_type=client_credentials" \
          --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)

        # Fetch secrets from HCP Vault
        curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
          --header "Authorization: Bearer $HCP_API_TOKEN" > /tmp/hcp_secrets.json

        # Generate /etc/default/alloy from HCP secrets
        HOSTNAME="{{ grains['hostname'] }}"
        cat <<EOF > /etc/default/alloy
        HOSTNAME=${HOSTNAME}
        GRAFANA_ALLOY_LOCAL_WRITE=true
        GRAFANA_LOKI_URL=$(jq -r '.secrets[] | select(.name=="GRAFANA_LOKI_URL") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_LOKI_USERNAME=$(jq -r '.secrets[] | select(.name=="GRAFANA_LOKI_USERNAME") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_LOKI_PASSWORD=$(jq -r '.secrets[] | select(.name=="GRAFANA_LOKI_PASSWORD") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_PROM_URL=$(jq -r '.secrets[] | select(.name=="GRAFANA_PROM_URL") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_PROM_USERNAME=$(jq -r '.secrets[] | select(.name=="GRAFANA_PROM_USERNAME") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_PROM_PASSWORD=$(jq -r '.secrets[] | select(.name=="GRAFANA_PROM_PASSWORD") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_FLEET_REMOTECFG_URL=$(jq -r '.secrets[] | select(.name=="GRAFANA_FLEET_REMOTECFG_URL") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_FLEET_COLLECTOR_URL=$(jq -r '.secrets[] | select(.name=="GRAFANA_FLEET_COLLECTOR_URL") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_FLEET_PIPELINE_URL=$(jq -r '.secrets[] | select(.name=="GRAFANA_FLEET_PIPELINE_URL") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_FLEET_USERNAME=$(jq -r '.secrets[] | select(.name=="GRAFANA_FLEET_USERNAME") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_FLEET_PASSWORD=$(jq -r '.secrets[] | select(.name=="GRAFANA_FLEET_PASSWORD") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_TRACES_URL=$(jq -r '.secrets[] | select(.name=="GRAFANA_TRACES_URL") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_TRACES_USERNAME=$(jq -r '.secrets[] | select(.name=="GRAFANA_TRACES_USERNAME") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_TRACES_PASSWORD=$(jq -r '.secrets[] | select(.name=="GRAFANA_TRACES_PASSWORD") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        EOF

        # Secure the file
        chmod 600 /etc/default/alloy
        chown alloy:alloy /etc/default/alloy

        # Clean up temporary file
        rm -f /tmp/hcp_secrets.json
    - require_in:
        - cmd: secure_alloy_file

# Ensure `/etc/default/alloy` is properly secured
secure_alloy_file:
  file.managed:
    - name: /etc/default/alloy
    - user: alloy
    - group: alloy
    - mode: 600
    - require:
      - cmd: fetch_hcp_secrets_and_set_env
