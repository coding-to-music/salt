# Fetch all secrets from HCP Vault and write them directly to the output file
fetch_hcp_secrets_and_set_env:
  cmd.run:
    - name: |
        LOG_FILE="/var/log/hcp_secrets.log"
        OUTPUT_FILE="/etc/default/alloy"

        # Log function to record timestamped entries
        log_message() {
          echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
        }

        # Static secrets list
        HOSTNAME="{{ grains['hostname'] }}"
        STATIC_ENTRIES=(
          "HOSTNAME=$HOSTNAME"
          "GRAFANA_ALLOY_LOCAL_WRITE=true"
        )

        # Secrets to extract
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

        # Fetch HCP API Token
        log_message "Fetching HCP API Token..."
        HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
          --header "Content-Type: application/x-www-form-urlencoded" \
          --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "grant_type=client_credentials" \
          --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)

        if [ -z "$HCP_API_TOKEN" ]; then
          log_message "Failed to fetch HCP API Token. Exiting."
          exit 1
        fi

        log_message "Successfully fetched HCP API Token."

        # Fetch all secrets from the API
        log_message "Fetching all secrets from the API..."
        SECRETS_JSON=$(curl -s --location "https://api.cloud.hashicorp.com/secrets/2023-11-28/organizations/2bca58f1-fcf2-4357-a7b2-2624255e4cc8/projects/60812beb-bdf1-4080-81a1-ec4f1f5af9fc/apps/alloy/secrets:open" \
          --request GET \
          --header "Authorization: Bearer $HCP_API_TOKEN")

        if [ -z "$SECRETS_JSON" ]; then
          log_message "Failed to fetch secrets from API. Exiting."
          exit 1
        fi

        log_message "Successfully fetched all secrets."

        # Write static entries to the output file
        > $OUTPUT_FILE
        for entry in "${STATIC_ENTRIES[@]}"; do
          echo "$entry" >> $OUTPUT_FILE
        done

        # Extract and write each secret to the output file
        for secret_name in "${SECRETS[@]}"; do
          log_message "Extracting secret: $secret_name"
          secret_value=$(echo "$SECRETS_JSON" | jq -r --arg name "$secret_name" '.secrets[] | select(.name == $name) | .static_version.value // "missing"')

          if [ "$secret_value" == "missing" ]; then
            log_message "Secret $secret_name not found. Writing as 'missing'."
          else
            log_message "Successfully extracted $secret_name."
          fi

          # Write the secret to the output file
          echo "${secret_name}=${secret_value}" >> $OUTPUT_FILE
        done

        # Set permissions for the output file
        chmod 600 $OUTPUT_FILE
        chown alloy:alloy $OUTPUT_FILE
        log_message "$OUTPUT_FILE successfully created."
    - shell: /bin/bash
