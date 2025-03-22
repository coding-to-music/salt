# Add the Grafana repository
grafana_repo:
  cmd.run:
    - name: |
        wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
        echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
        sudo apt-get update
    - unless: test -f /etc/apt/keyrings/grafana.gpg

# Install the Alloy collector
alloy_install:
  pkg.installed:
    - name: alloy

# Backup existing config.alloy if it exists
backup_config_alloy:
  cmd.run:
    - name: sudo cp -p /etc/alloy/config.alloy /etc/alloy/config.alloy.$(date +%Y-%m-%d_%H-%M-%S)
    - unless: test -f /etc/alloy/config.alloy

# Download and replace with new config.alloy
replace_config_alloy:
  cmd.run:
    - name: |
        wget -O /etc/alloy/config.alloy https://raw.githubusercontent.com/coding-to-music/grafana-alloy-otel-tutorial-loki-prometheus/refs/heads/main/my_config.alloy
    - require:
      - cmd: backup_config_alloy

# Fetch secrets from HCP Vault and write them to /etc/default/alloy
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
    - require:
      - pkg: alloy_install
      - cmd: replace_config_alloy

# Ensure Alloy is running
alloy_service:
  service.running:
    - name: alloy
    - enable: True
    - watch:
      - cmd: fetch_hcp_secrets_and_configure_alloy
      - cmd: replace_config_alloy
    - require:
      - cmd: fetch_hcp_secrets_and_configure_alloy
      - cmd: replace_config_alloy

# Download and install Node Exporter
install_node_exporter:
  cmd.run:
    - name: |
        NODE_EXPORTER_VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
        wget https://github.com/prometheus/node_exporter/releases/download/${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION:1}.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
        tar xvfz /tmp/node_exporter.tar.gz -C /tmp
        sudo mv /tmp/node_exporter-${NODE_EXPORTER_VERSION:1}.linux-amd64/node_exporter /usr/local/bin/
    - unless: test -f /usr/local/bin/node_exporter

# Create a systemd service for Node Exporter
node_exporter_service:
  file.managed:
    - name: /etc/systemd/system/node_exporter.service
    - contents: |
        [Unit]
        Description=Node Exporter
        After=network.target

        [Service]
        User=node_exporter
        ExecStart=/usr/local/bin/node_exporter

        [Install]
        WantedBy=multi-user.target
    - require:
      - cmd: install_node_exporter

# Create the Node Exporter user
create_node_exporter_user:
  cmd.run:
    - name: sudo useradd -rs /bin/false node_exporter
    - unless: id -u node_exporter

# Set permissions for Node Exporter binary
set_node_exporter_permissions:
  cmd.run:
    - name: sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
    - require:
      - cmd: install_node_exporter
      - cmd: create_node_exporter_user

# Enable and start Node Exporter service
start_node_exporter:
  service.running:
    - name: node_exporter
    - enable: True
    - watch:
      - file: node_exporter_service
      - cmd: set_node_exporter_permissions
