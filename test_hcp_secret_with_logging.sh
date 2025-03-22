#!/bin/bash

# File: test_hcp_secret_with_logging.sh

# Set the path to your .env file
ENV_FILE="/srv/salt/.env"

# Set the path to the log file
LOG_FILE="/var/log/hcp_secret_test.log"

# Log function to record timestamped entries
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Start the logging
log_message "Starting test script to fetch secret."

# Load environment variables from the .env file
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
  log_message "Environment variables loaded from $ENV_FILE."
else
  log_message ".env file not found at $ENV_FILE. Exiting."
  exit 1
fi

# Check that required variables are set
if [ -z "$HCP_CLIENT_ID" ] || [ -z "$HCP_CLIENT_SECRET" ] || [ -z "$HCP_SECRETS_URL" ]; then
  log_message "Missing required environment variables (HCP_CLIENT_ID, HCP_CLIENT_SECRET, HCP_SECRETS_URL). Exiting."
  exit 1
fi

# Specify the secret name to fetch
SECRET_NAME="GRAFANA_FLEET_PIPELINE_URL"
log_message "Targeting secret: $SECRET_NAME."

# Fetch the API Token
log_message "Fetching HCP API Token..."
HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=$HCP_CLIENT_ID" \
  --data-urlencode "client_secret=$HCP_CLIENT_SECRET" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r '.access_token')

if [ -z "$HCP_API_TOKEN" ] || [ "$HCP_API_TOKEN" == "null" ]; then
  log_message "Failed to fetch HCP API Token. Please check your credentials. Exiting."
  exit 1
else
  log_message "Successfully fetched HCP API Token: $HCP_API_TOKEN."
fi

# Log the URL being requested
log_message "Using HCP_SECRETS_URL: $HCP_SECRETS_URL/$SECRET_NAME."

# Fetch the secret value
log_message "Fetching secret: $SECRET_NAME."
RESPONSE=$(curl -s --location "$HCP_SECRETS_URL/$SECRET_NAME" \
  --header "Authorization: Bearer $HCP_API_TOKEN" \
  --header "Content-Type: application/json")

log_message "API Response: $RESPONSE."

SECRET_VALUE=$(echo "$RESPONSE" | jq -r '.secret.version.value')

if [ -z "$SECRET_VALUE" ] || [ "$SECRET_VALUE" == "null" ]; then
  log_message "Failed to fetch secret $SECRET_NAME. It may not exist or may be inaccessible."
else
  log_message "Successfully fetched secret $SECRET_NAME: $SECRET_VALUE."
fi

log_message "Script completed."
