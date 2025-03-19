# Fetch secrets from HCP Vault, handle retries, and handle pagination
fetch_hcp_secrets_and_set_env:
  cmd.run:
    - name: |
        # Set the log file and secrets file locations
        LOG_FILE="/var/log/hcp_secrets.log"
        SECRETS_FILE="/tmp/hcp_secrets_combined.json"

        # Log function to record timestamped entries
        log_message() {
          echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
        }

        # Function to fetch secrets, including handling pagination
        fetch_all_secrets() {
          local HCP_API_TOKEN
          local next_page_token=""
          local previous_page_token=""
          local secrets_count=0
          local combined_count=0
          local last_combined_count=0
          local iteration=0

          # Initialize or empty the combined secrets file
          echo "[]" > $SECRETS_FILE

          # Fetch HCP API Token
          log_message "Fetching HCP API Token..."
          HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
            --header "Content-Type: application/x-www-form-urlencoded" \
            --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
            --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
            --data-urlencode "grant_type=client_credentials" \
            --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)

          if [ -z "$HCP_API_TOKEN" ]; then
            log_message "Failed to fetch HCP API Token."
            exit 1
          fi

          log_message "Successfully fetched HCP API Token."

          # Fetch secrets with pagination
          while :; do
            iteration=$((iteration + 1))
            log_message "Iteration $iteration - Fetching secrets, next_page_token: $next_page_token"

            # Make API call to fetch secrets
            response=$(curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
              --header "Authorization: Bearer $HCP_API_TOKEN" \
              --data-urlencode "page_token=$next_page_token")

            # Extract secrets and pagination info
            secrets=$(echo "$response" | jq '.secrets')
            next_page_token=$(echo "$response" | jq -r '.pagination.next_page_token')
            secrets_count=$(echo "$secrets" | jq 'length')

            # Log the number of secrets fetched on this page
            log_message "Secrets fetched on this page: $secrets_count."

            # Break if no secrets are returned
            if [ "$secrets_count" -eq 0 ]; then
              log_message "No secrets returned on this page. Breaking loop."
              break
            fi

            # Combine the secrets from this page into the combined file
            jq -s '.[0] + .[1]' $SECRETS_FILE <(echo "$secrets") > /tmp/temp_secrets.json
            mv /tmp/temp_secrets.json $SECRETS_FILE

            # Count the current number of combined secrets
            combined_count=$(jq '. | length' $SECRETS_FILE)

            # Log the combined secret count
            log_message "Combined secrets so far: $combined_count."

            # Break if no new secrets are added
            if [ "$combined_count" -eq "$last_combined_count" ]; then
              log_message "No new secrets added. Breaking loop to avoid duplication."
              break
            fi

            # Break if the next_page_token has not changed
            if [ "$next_page_token" == "$previous_page_token" ]; then
              log_message "Detected repeated next_page_token ($next_page_token). Breaking loop."
              break
            fi

            # Update the last combined count and previous page token
            last_combined_count=$combined_count
            previous_page_token=$next_page_token

            # Break if no valid next_page_token
            if [ "$next_page_token" == "null" ] || [ -z "$next_page_token" ]; then
              log_message "No more pages to fetch. All secrets retrieved."
              break
            fi

            # Add a short delay to avoid hitting rate limits
            sleep 1
          done

          log_message "All secrets fetched. Total combined secrets: $combined_count."
        }

        # Retry function with exponential backoff
        fetch_with_retries() {
          local retries=5
          local delay=1
          local attempt=0

          while [ $attempt -lt $retries ]; do
            log_message "Attempt $((attempt+1)) of $retries to fetch all secrets..."
            if fetch_all_secrets; then
              return 0
            fi

            log_message "Failed attempt $((attempt+1)). Retrying in $delay seconds..."
            sleep $delay
            attempt=$((attempt+1))
            delay=$((delay * 2)) # Exponential backoff
          done

          log_message "Failed to fetch secrets after $retries attempts."
          exit 1
        }

        # Fetch secrets with retries
        fetch_with_retries

        # Generate /etc/default/alloy from combined secrets
        HOSTNAME="{{ grains['hostname'] }}" # Include the hostname dynamically
        cat <<EOF > /etc/default/alloy
        HOSTNAME=${HOSTNAME}
        GRAFANA_ALLOY_LOCAL_WRITE=true
        GRAFANA_LOKI_URL=$(jq -r '.[] | select(.name=="GRAFANA_LOKI_URL") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_LOKI_USERNAME=$(jq -r '.[] | select(.name=="GRAFANA_LOKI_USERNAME") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_LOKI_PASSWORD=$(jq -r '.[] | select(.name=="GRAFANA_LOKI_PASSWORD") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_PROM_URL=$(jq -r '.[] | select(.name=="GRAFANA_PROM_URL") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_PROM_USERNAME=$(jq -r '.[] | select(.name=="GRAFANA_PROM_USERNAME") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_PROM_PASSWORD=$(jq -r '.[] | select(.name=="GRAFANA_PROM_PASSWORD") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_FLEET_REMOTECFG_URL=$(jq -r '.[] | select(.name=="GRAFANA_FLEET_REMOTECFG_URL") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_FLEET_COLLECTOR_URL=$(jq -r '.[] | select(.name=="GRAFANA_FLEET_COLLECTOR_URL") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_FLEET_PIPELINE_URL=$(jq -r '.[] | select(.name=="GRAFANA_FLEET_PIPELINE_URL") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_FLEET_USERNAME=$(jq -r '.[] | select(.name=="GRAFANA_FLEET_USERNAME") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_FLEET_PASSWORD=$(jq -r '.[] | select(.name=="GRAFANA_FLEET_PASSWORD") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_TRACES_URL=$(jq -r '.[] | select(.name=="GRAFANA_TRACES_URL") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_TRACES_USERNAME=$(jq -r '.[] | select(.name=="GRAFANA_TRACES_USERNAME") | .static_version.value // "missing"' $SECRETS_FILE)
        GRAFANA_TRACES_PASSWORD=$(jq -r '.[] | select(.name=="GRAFANA_TRACES_PASSWORD") | .static_version.value // "missing"' $SECRETS_FILE)
        EOF

        # Secure the file
        chmod 600 /etc/default/alloy
        chown alloy:alloy /etc/default/alloy

        # Count the total number of secrets and log it
        total_secrets=$(jq '. | length' $SECRETS_FILE)
        log_message "Total number of secrets fetched: $total_secrets"

        # Clean up temporary files
        rm -f $SECRETS_FILE
        log_message "/etc/default/alloy successfully created."
    - shell: /bin/bash
