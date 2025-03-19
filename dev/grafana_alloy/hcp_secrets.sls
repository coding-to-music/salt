# Fetch secrets from HCP Vault and write them to /etc/default/alloy with retries, logging, and backoff
fetch_hcp_secrets_and_set_env:
  cmd.run:
    - name: |
        LOG_FILE="/var/log/hcp_secrets.log"
        
        # Log function to record timestamped entries
        log_message() {
          echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
        }

        # Retry function with exponential backoff
        fetch_secrets_with_retries() {
          local retries=5
          local delay=1
          local attempt=0
          
          while [ $attempt -lt $retries ]; do
            log_message "Attempt $((attempt+1)) of $retries: Fetching HCP API Token and secrets..."
            
            # Fetch HCP API Token
            HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
              --header "Content-Type: application/x-www-form-urlencoded" \
              --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
              --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
              --data-urlencode "grant_type=client_credentials" \
              --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)
            
            if [ -z "$HCP_API_TOKEN" ]; then
              log_message "Failed to fetch HCP API Token. Retrying in $delay seconds..."
              sleep $delay
              attempt=$((attempt+1))
              delay=$((delay * 2)) # Exponential backoff
              continue
            fi
            
            # Fetch secrets from HCP
            curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
              --header "Authorization: Bearer $HCP_API_TOKEN" > /tmp/hcp_secrets.json
            
            # Validate the fetched secrets file
            if [ -s /tmp/hcp_secrets.json ] && jq -e .secrets[] /tmp/hcp_secrets.json > /dev/null 2>&1; then
              log_message "Successfully fetched secrets from HCP."
              return 0
            fi
            
            log_message "Failed to fetch secrets. Retrying in $delay seconds..."
            sleep $delay
            attempt=$((attempt+1))
            delay=$((delay * 2)) # Exponential backoff
          done
          
          log_message "Failed to fetch secrets after $retries attempts."
          return 1
        }

        # Fetch secrets with retries
        fetch_secrets_with_retries || exit 1
        
        # Generate /etc/default/alloy from HCP secrets
        HOSTNAME="{{ grains['hostname'] }}" # Include the hostname dynamically
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
        log_message "/etc/default/alloy successfully created."
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
