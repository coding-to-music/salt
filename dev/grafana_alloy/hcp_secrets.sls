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
    log_message "Fetching secrets, next_page_token: $next_page_token"

    # Make API call to fetch secrets
    response=$(curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
      --header "Authorization: Bearer $HCP_API_TOKEN" \
      --data-urlencode "page_token=$next_page_token")

    # Extract secrets and pagination info
    secrets=$(echo "$response" | jq '.secrets')
    next_page_token=$(echo "$response" | jq -r '.pagination.next_page_token')

    # Check if the next_page_token is the same as the previous one
    if [ "$next_page_token" == "$previous_page_token" ]; then
      log_message "Detected repeated next_page_token. Breaking the loop to prevent infinite requests."
      break
    fi

    # Combine the secrets from this page into the combined file
    jq -s '.[0] + .[1]' $SECRETS_FILE <(echo "$secrets") > /tmp/temp_secrets.json
    mv /tmp/temp_secrets.json $SECRETS_FILE

    # Break the loop if no next page
    if [ "$next_page_token" == "null" ] || [ -z "$next_page_token" ]; then
      log_message "No more pages to fetch. All secrets retrieved."
      break
    fi

    # Update the previous_page_token for the next iteration
    previous_page_token=$next_page_token

    # Add a short delay to avoid hitting rate limits
    sleep 1
  done

  # Count the number of secrets
  secret_count=$(jq '. | length' $SECRETS_FILE)
  log_message "Total number of secrets fetched: $secret_count"

  log_message "All secrets fetched and combined into $SECRETS_FILE."
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
