## Grafana Alloy

Step 1: Create or Edit the Grains File

Salt grains can be defined in `/etc/salt/grains`. If the file doesn't exist, you can create it.

Open the grains file:

```java
sudo nano /etc/salt/grains
```

Add or edit the hostname grain. For example, for server1:

```java
hostname: server1
```

Save the file and exit.

Step 2: Refresh Grains

Once you've updated the grains file, instruct Salt to refresh grains:

```java
sudo salt '*' saltutil.sync_grains

# or

sudo salt '*' saltutil.refresh_grains
```

Step 3: Verify the Hostname Grain

Ensure that the custom grain is set correctly by running:

```java
sudo salt '*' grains.items

# or

sudo salt '*' grains.item hostname | grep -A 1 hostname

# or

sudo salt '*' grains.item hostname
```

Look for the hostname entry in the output to confirm it's set to your custom value.

Additional Notes

- If you want to specify the hostname dynamically when applying the Salt state, you can also pass it as a pillar

```java
sudo salt '*' state.apply grafana_alloy.install pillar="{HOSTNAME: server1}"
```

Salt state `alloy_config_using_hcp_secrets.sls` will create file `/etc/default/alloy`

```java
HOSTNAME=from_grains 
GRAFANA_ALLOY_LOCAL_WRITE=true
GRAFANA_LOKI_URL=secret
GRAFANA_LOKI_USERNAME=secret
GRAFANA_LOKI_PASSWORD=secret
GRAFANA_PROM_URL=secret
GRAFANA_PROM_USERNAME=secret
GRAFANA_PROM_PASSWORD=secret
GRAFANA_FLEET_REMOTECFG_URL=secret
GRAFANA_FLEET_COLLECTOR_URL=secret
GRAFANA_FLEET_PIPELINE_URL=secret
GRAFANA_FLEET_USERNAME=secret
GRAFANA_FLEET_PASSWORD=secret
GRAFANA_TRACES_URL=secret
GRAFANA_TRACES_USERNAME=secret
GRAFANA_TRACES_PASSWORD=secret
```

Salt commands for Alloy

```java
sudo systemctl restart salt-master

sudo systemctl restart salt-minion

cat /etc/default/alloy

./test_hcp_secret.sh

./test_hcp_secret_with_pagination.sh

sudo ./test_hcp_secret_with_logging.sh

rm /etc/default/alloy

rm /var/log/alloy_config_using_hcp_secrets.log

sudo salt '*' state.apply grafana_alloy.alloy_config_using_hcp_secrets saltenv=dev

cat /etc/default/alloy

cat /var/log/alloy_config_using_hcp_secrets.log

sudo salt '*' state.apply grafana_alloy.install saltenv=dev  

sudo salt '*' state.apply grafana_alloy.install saltenv=dev  --timeout=120

sudo salt '*' state.apply grafana_alloy.uninstall saltenv=dev

sudo salt '*' state.apply grafana_alloy.upgrade saltenv=dev

sudo salt '*' state.apply grafana_alloy.start saltenv=dev

sudo salt '*' state.apply grafana_alloy.stop saltenv=dev
```

### If minion does not return or complete

Check Minion Connectivity

```java
sudo salt '*' test.ping
```

Run the State Directly on the Minion

Since the master isn't processing the job correctly, you can bypass the master and run the Salt state locally on the minion using `salt-call`

```java
sudo salt-call state.apply alloy_config_using_hcp_secrets saltenv=dev
```

Manually read the second page of the secrets

```java
HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
  --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)

curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
  --header "Authorization: Bearer $HCP_API_TOKEN" \
  --data-urlencode "page_token=CiRXeUpIVWtGR1FVNUJYMHhQUzBsZlZWTkZVazVCVFVVaVhRPT0=" | jq
```


Check the logs

```java
# check the target output file that should be created

cat /etc/default/alloy

cat /var/log/alloy_config_using_hcp_secrets.log

cat /var/log/alloy_config_using_hcp_secrets.log

tail /var/log/alloy_config_using_hcp_secrets.log

sudo tail -f /var/log/salt/master

sudo tail -f /var/log/salt/minion
```

If you suspect the state isn't applying due to connectivity issues, manually verify if the /etc/default/alloy file can be created by running the commands directly:

```java
HCP_API_TOKEN=$(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=$(grep HCP_CLIENT_ID /srv/salt/.env | cut -d '=' -f2)" \
  --data-urlencode "client_secret=$(grep HCP_CLIENT_SECRET /srv/salt/.env | cut -d '=' -f2)" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)

curl -s --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
  --header "Authorization: Bearer $HCP_API_TOKEN" > /tmp/hcp_secrets.json

HOSTNAME=$(hostname)
cat <<EOF > /etc/default/alloy
HOSTNAME=${HOSTNAME}
GRAFANA_ALLOY_LOCAL_WRITE=true
# Add remaining environment variables here...
EOF

chmod 600 /etc/default/alloy
```

Check for Throttling or API Limits

HashiCorp APIs could enforce rate limits or quotas that throttle your requests. Here’s how to identify if this is happening:

Inspect API Response: Review the response of the curl command in your script to see if it indicates throttling. Add a debug flag to curl:

```java
curl -v --location "$(grep HCP_SECRETS_URL /srv/salt/.env | cut -d '=' -f2)" \
  --header "Authorization: Bearer $HCP_API_TOKEN" > /tmp/hcp_secrets.json
```

Look for HTTP status codes:

`429` Too Many Requests: Indicates throttling.

`500/503`: Suggests server-side issues or rate limits.

```java
cd /var/cache/salt/minion/proc
ls -lat
```

Verify the secrets file is being created

```java
cat /etc/default/alloy

ls -lat /etc/default/alloy
```

Verify Services:

Check Node Exporter metrics at `http://<hostname>:9100/metrics`

Verify that Alloy is running:

```java
sudo systemctl status alloy
cat /etc/alloy/config.alloy
```

Verify that node_exporter is running:

```java
sudo systemctl status node_exporter
curl http://localhost:9100/metrics
```

## Retrieve a single secret value from HashiCorp Cloud Platform (HCP) Vault Secrets

To retrieve a single secret value from HashiCorp Cloud Platform (HCP) Vault Secrets by supplying the secret name, you can use the HCP Vault Secrets API. Below is a step-by-step guide to make such a request using curl. This assumes you have already set up your HCP Vault Secrets environment with an application and secrets.

Prerequisites

HCP Credentials: You need a service principal with a Client ID and Client Secret to authenticate with HCP.

Environment Variables: Set up the following variables:

- `HCP_CLIENT_ID`: Your HCP service principal Client ID.
- `HCP_CLIENT_SECRET`: Your HCP service principal Client Secret.
- `HCP_ORG_ID`: Your HCP organization ID.
- `HCP_PROJECT_ID`: Your HCP project ID.
- `VLT_APPS_NAME`: The name of the application in HCP Vault Secrets where your secret is stored.
- `SECRET_NAME`: The name of the specific secret you want to retrieve (e.g., my_secret_name).

You can export these in your terminal like this:

```java
export HCP_CLIENT_ID="your-client-id"
export HCP_CLIENT_SECRET="your-client-secret"
export HCP_ORG_ID="your-org-id"
export HCP_PROJECT_ID="your-project-id"
export VLT_APPS_NAME="your-app-name"
export SECRET_NAME="my_secret_name"
```

Authentication Token: You’ll need to obtain an API token using your Client ID and Client Secret.

Steps to Retrieve a Single Secret

1. Obtain an API Token

First, authenticate with the HCP API to get a bearer token. Run the following curl command:

```java
HCP_API_TOKEN=$(curl -s --location --request POST "https://auth.idp.hashicorp.com/oauth2/token" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=$HCP_CLIENT_ID" \
  --data-urlencode "client_secret=$HCP_CLIENT_SECRET" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r '.access_token')
```

This command:

- Sends a POST request to the HCP authentication endpoint.
- Uses your Client ID and Secret to request an access token.
- Extracts the token using jq and stores it in the HCP_API_TOKEN variable.

2. Request the Specific Secret

Now, use the token to request the value of a single secret by its name. Replace $SECRET_NAME with the name of the secret you want (e.g., my_secret_name):

```java
curl --silent \
  --header "Authorization: Bearer $HCP_API_TOKEN" \
  --header "Content-Type: application/json" \
  --location "https://api.cloud.hashicorp.com/secrets/2023-06-13/organizations/$HCP_ORG_ID/projects/$HCP_PROJECT_ID/apps/$VLT_APPS_NAME/open/$SECRET_NAME" | jq -r '.secret.version.value'
```

Get full JSON to see all available results

```java
curl --silent \
  --header "Authorization: Bearer $HCP_API_TOKEN" \
  --header "Content-Type: application/json" \
  --location "https://api.cloud.hashicorp.com/secrets/2023-06-13/organizations/$HCP_ORG_ID/projects/$HCP_PROJECT_ID/apps/$VLT_APPS_NAME/open/$SECRET_NAME" | jq 
```

This command:

- Makes a GET request to the HCP Vault Secrets API endpoint for opening a specific secret.
- Specifies the organization, project, application, and secret name in the URL.
- Uses the bearer token for authorization.
- Extracts only the secret value using `jq -r '.secret.value'`

Example Output

If your secret `my_secret_name` has the value `my_secret_value`, the output will be:

```java
my_secret_value
```

