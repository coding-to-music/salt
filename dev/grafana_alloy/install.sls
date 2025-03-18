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

        # Fetch secrets from HCP and save temporarily
        curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
          --header "Authorization: Bearer $HCP_API_TOKEN" > /tmp/hcp_secrets.json

        # Generate /etc/default/alloy from HCP secrets
        HOSTNAME="{{ grains['hostname'] }}" # Include the hostname dynamically
        cat <<EOF > /etc/default/alloy
        HOSTNAME=${HOSTNAME}
        GRAFANA_LOKI_URL=$(jq -r '.secrets[] | select(.name=="GRAFANA_LOKI_URL") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_LOKI_USERNAME=$(jq -r '.secrets[] | select(.name=="GRAFANA_LOKI_USERNAME") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_LOKI_PASSWORD=$(jq -r '.secrets[] | select(.name=="GRAFANA_LOKI_PASSWORD") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_PROM_URL=$(jq -r '.secrets[] | select(.name=="GRAFANA_PROM_URL") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_PROM_USERNAME=$(jq -r '.secrets[] | select(.name=="GRAFANA_PROM_USERNAME") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        GRAFANA_PROM_PASSWORD=$(jq -r '.secrets[] | select(.name=="GRAFANA_PROM_PASSWORD") | .static_version.value // "missing"' /tmp/hcp_secrets.json)
        EOF

        # Secure /etc/default/alloy
        chmod 600 /etc/default/alloy
        chown alloy:alloy /etc/default/alloy

        # Remove temporary HCP secrets file
        rm -f /tmp/hcp_secrets.json
    - require:
      - pkg: alloy_install
      - cmd: replace_config_alloy

# Ensure Alloy is running
alloy_service:
  service.running:
    - name: alloy
    - enable: True
    - watch:
      - cmd: fetch_hcp_secrets_and_set_env
      - file: /etc/alloy/config.alloy
    - require:
      - cmd: fetch_hcp_secrets_and_set_env

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
