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

# Fetch secrets dynamically from HCP Vault and use them in Alloy
fetch_hcp_secrets_and_configure_alloy:
  cmd.run:
    - name: |
        HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
          --header "Content-Type: application/x-www-form-urlencoded" \
          --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
          --data-urlencode "grant_type=client_credentials" \
          --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)
        curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
          --header "Authorization: Bearer $HCP_API_TOKEN" | jq -r '.secrets' > /etc/alloy/hcp_secrets.json
        HOSTNAME="{{ grains['hostname'] }}" # Dynamically include the hostname
        jq -n \
        --arg loki_url "$(jq -r '.GRAFANA_LOKI_URL' /etc/alloy/hcp_secrets.json)" \
        --arg loki_user "$(jq -r '.GRAFANA_LOKI_USERNAME' /etc/alloy/hcp_secrets.json)" \
        --arg loki_pass "$(jq -r '.GRAFANA_LOKI_PASSWORD' /etc/alloy/hcp_secrets.json)" \
        --arg prom_url "$(jq -r '.GRAFANA_PROM_URL' /etc/alloy/hcp_secrets.json)" \
        --arg prom_user "$(jq -r '.GRAFANA_PROM_USERNAME' /etc/alloy/hcp_secrets.json)" \
        --arg prom_pass "$(jq -r '.GRAFANA_PROM_PASSWORD' /etc/alloy/hcp_secrets.json)" \
        --arg hostname "$HOSTNAME" \
        '{loki_url: $loki_url, loki_user: $loki_user, loki_pass: $loki_pass, prom_url: $prom_url, prom_user: $prom_user, prom_pass: $prom_pass, hostname: $hostname}' > /etc/alloy/config.alloy
    - require:
      - pkg: alloy_install

# Ensure Alloy is running
alloy_service:
  service.running:
    - name: alloy-server
    - enable: True
    - watch:
      - cmd: fetch_hcp_secrets_and_configure_alloy

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
