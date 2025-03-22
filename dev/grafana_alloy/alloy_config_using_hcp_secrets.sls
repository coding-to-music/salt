# alloy_config_using_hcp_secrets.sls

fetch_hcp_secrets_and_configure_alloy:
  cmd.run:
    - name: |
        LOG_FILE="/var/log/alloy_config_using_hcp_secrets.log"
        OUTPUT_FILE="/etc/default/alloy"

        # Log function to record timestamped entries
        log_message() {
          echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
        }

        # Back up the existing file if it exists
        if [ -f "$OUTPUT_FILE" ]; then
          log_message "Backing up existing $OUTPUT_FILE."
          cp "$OUTPUT_FILE" "${OUTPUT_FILE}.$(date '+%Y%m%d%H%M%S').bak"
        fi

        # Load environment variables from the .env file
        ENV_FILE="/srv/salt/.env"
        if [ -f "$ENV_FILE" ]; then
          export $(grep -v '^#' "$ENV_FILE" | xargs)
          log_message "Loaded environment variables from $ENV_FILE."
        else
          log_message ".env file not found. Exiting."
          exit 1
        fi

        # Fetch HCP API Token
        log_message "Fetching HCP API Token..."
        HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
          --header "Content-Type: application/x-www-form-urlencoded" \
          --data-urlencode "client_id=$HCP_CLIENT_ID" \
          --data-urlencode "client_secret=$HCP_CLIENT_SECRET" \
          --data-urlencode "grant_type=client_credentials" \
          --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r '.access_token')

        if [ -z "$HCP_API_TOKEN" ]; then
          log_message "Failed to fetch HCP API Token. Exiting."
          exit 1
        fi

        log_message "Successfully fetched HCP API Token."

        # Write static entries to the output file
        > $OUTPUT_FILE
        echo "HOSTNAME={{ grains['hostname'] }}" >> $OUTPUT_FILE
        echo "GRAFANA_ALLOY_LOCAL_WRITE=true" >> $OUTPUT_FILE
        log_message "Static entries written to $OUTPUT_FILE."

        # Fetch and write each secret value
        SECRETS=(
          "GRAFANA_LOKI_URL"
          "GRAFANA_LOKI_USERNAME"
          "GRAFANA_LOKI_PASSWORD"
          "GRAFANA_PROM_URL"
          "GRAFANA_PROM_USERNAME"
          "GRAFANA_PROM_PASSWORD"
          "GRAFANA_FLEET_REMOTECFG_URL"
          "GRAFANA_FLEET_COLLECTOR_URL"
          "GRAFANA_FLEET_PIPELINE_URL"
          "GRAFANA_FLEET_USERNAME"
          "GRAFANA_FLEET_PASSWORD"
          "GRAFANA_TRACES_URL"
          "GRAFANA_TRACES_USERNAME"
          "GRAFANA_TRACES_PASSWORD"
        )

        echo 

        for secret_name in "${SECRETS[@]}"; do
          log_message "Fetching secret: $secret_name"
          SECRET_VALUE=$(curl -s --location "$HCP_SECRETS_URL/$secret_name" \
            --request GET \
            --header "Authorization: Bearer $HCP_API_TOKEN" | jq -r '.secret.version.value')

          if [ -z "$SECRET_VALUE" ] || [ "$SECRET_VALUE" == "null" ]; then
            log_message "Secret $secret_name not found or empty. Writing as 'missing'."
            SECRET_VALUE="missing"
          else
            log_message "Successfully fetched secret: $secret_name."
          fi

          echo "${secret_name}=${SECRET_VALUE}" >> $OUTPUT_FILE
        done

        # Set permissions for the output file
        chmod 600 $OUTPUT_FILE
        chown alloy:alloy $OUTPUT_FILE
        log_message "$OUTPUT_FILE successfully created."
    - shell: /bin/bash
