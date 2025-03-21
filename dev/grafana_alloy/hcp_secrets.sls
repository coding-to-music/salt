# Fetch secrets from HCP Vault and write directly to the output file
fetch_hcp_secrets_and_set_env:
  cmd.run:
    - name: |
        LOG_FILE="/var/log/hcp_secrets.log"

        # Log function to record timestamped entries
        log_message() {
          echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
        }

        # Initialize variables
        HOSTNAME="{{ grains['hostname'] }}"
        OUTPUT_FILE="/etc/default/alloy"
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

        # Write static entries to the output file
        echo "HOSTNAME=$HOSTNAME" > $OUTPUT_FILE
        echo "GRAFANA_ALLOY_LOCAL_WRITE=true" >> $OUTPUT_FILE

        # Fetch each secret and append to the output file
        for secret_name in "${SECRETS[@]}"; do
          log_message "Fetching secret: $secret_name"
          secret_value=$(curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
            --header "Authorization: Bearer $HCP_API_TOKEN" \
            --data-urlencode "name=$secret_name" | jq -r '.secrets[0].static_version.value // "missing"')

          if [ "$secret_value" == "missing" ]; then
            log_message "Secret $secret_name not found or has no value. Skipping."
            secret_value="missing"
          else
            log_message "Successfully fetched $secret_name."
          fi

          # Write the secret to the output file
          echo "${secret_name}=${secret_value}" >> $OUTPUT_FILE
        done

        # Set permissions for the output file
        chmod 600 $OUTPUT_FILE
        chown alloy:alloy $OUTPUT_FILE
        log_message "$OUTPUT_FILE successfully created."
    - shell: /bin/bash
