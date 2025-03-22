#!/bin/bash

# File: test_hcp_secret.sh

# Set the path to your .env file
ENV_FILE="/srv/salt/.env"

# Load environment variables from the .env file
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
  echo "Environment variables loaded from $ENV_FILE."
else
  echo ".env file not found. Please ensure it is at $ENV_FILE."
  exit 1
fi

# Check that required variables are set
if [ -z "$HCP_CLIENT_ID" ] || [ -z "$HCP_CLIENT_SECRET" ] || [ -z "$HCP_SECRETS_URL" ]; then
  echo "Missing required environment variables (HCP_CLIENT_ID, HCP_CLIENT_SECRET, HCP_SECRETS_URL)."
  exit 1
fi

# Specify the secret name to fetch
SECRET_NAME="GRAFANA_FLEET_PIPELINE_URL"

# Fetch the API Token
echo "Fetching HCP API Token..."
HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=$HCP_CLIENT_ID" \
  --data-urlencode "client_secret=$HCP_CLIENT_SECRET" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r '.access_token')

if [ -z "$HCP_API_TOKEN" ] || [ "$HCP_API_TOKEN" == "null" ]; then
  echo "Failed to fetch HCP API Token. Please check your credentials."
  exit 1
else
  echo "Successfully fetched HCP API Token."
fi

# Fetch the secret full json
echo "Fetching secret full json: $SECRET_NAME"
echo --location "$HCP_SECRETS_URL/$SECRET_NAME"
# echo --header "Authorization: Bearer $HCP_API_TOKEN"

curl -s --location "$HCP_SECRETS_URL/$SECRET_NAME" \
  --header "Authorization: Bearer $HCP_API_TOKEN" \
  --header "Content-Type: application/json" | jq 

# Fetch the secret value
echo "Fetching secret: $SECRET_NAME"
SECRET_VALUE=$(curl -s --location "$HCP_SECRETS_URL/$SECRET_NAME" \
  --header "Authorization: Bearer $HCP_API_TOKEN" \
  --header "Content-Type: application/json" | jq -r '.secret.version.value')

#  --header "Content-Type: application/json" | jq -r '.secret.version.value')

if [ -z "$SECRET_VALUE" ] || [ "$SECRET_VALUE" == "null" ]; then
  echo "Failed to fetch secret $SECRET_NAME. It may not exist or may be inaccessible."
else
  echo "Successfully fetched secret $SECRET_NAME: $SECRET_VALUE"
fi
