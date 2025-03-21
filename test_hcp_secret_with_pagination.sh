#!/bin/bash

# File: test_hcp_secret_with_pagination.sh

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
TARGET_SECRET="GRAFANA_PROM_URL"

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

# Fetch all secrets from the API with pagination
NEXT_PAGE_URL="$HCP_SECRETS_URL"
SECRET_VALUE=""

echo "Fetching secrets using pagination..."
while [ -n "$NEXT_PAGE_URL" ] && [ "$NEXT_PAGE_URL" != "null" ]; do
  RESPONSE=$(curl -s --location "$NEXT_PAGE_URL" \
    --header "Authorization: Bearer $HCP_API_TOKEN" \
    --header "Content-Type: application/json")

  # Extract secrets and the next page URL
  SECRET_VALUE=$(echo "$RESPONSE" | jq -r --arg name "$TARGET_SECRET" '.secrets[] | select(.name == $name) | .static_version.value // empty')
  NEXT_PAGE_URL=$(echo "$RESPONSE" | jq -r '.next_page_url')

  # If the secret is found, exit the loop
  if [ -n "$SECRET_VALUE" ]; then
    break
  fi
done

# Check if the secret was found
if [ -z "$SECRET_VALUE" ]; then
  echo "Failed to fetch secret $TARGET_SECRET. It may not exist or may be inaccessible."
else
  echo "Successfully fetched secret $TARGET_SECRET: $SECRET_VALUE"
fi
