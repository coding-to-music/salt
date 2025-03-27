## Hashicorp HCP Vault

https://portal.cloud.hashicorp.com/sign-in

https://developer.hashicorp.com/hcp/tutorials

https://developer.hashicorp.com/hcp/docs/vault-secrets/get-started/plan-implementation/tiers-features

Manual Install

https://developer.hashicorp.com/hcp/tutorials/get-started-hcp-vault-secrets/hcp-vault-secrets-install-cli

### Manual Install HCP CLI

```java
# Update the apt repository
sudo apt-get update && \
  sudo apt-get install gpg coreutils

# Download the HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add the HashiCorp repo
sudo apt update && sudo apt install hcp -y
```

### Setup HCP CLI

a. Login to the HashiCorp Cloud Platform to access HVS.

```java
hcp auth login

# click on the link to open a browser to authenticate
```

b. Once successfully logged in run:

```java
hcp profile init --vault-secrets
```

c. Now set your default config by selecting Organization, Project, and App.

Read your secret

```java
hcp vault-secrets secrets open YOUR_SECRET_NAME
```

Output

```java
Secret Name:    YOUR_SECRET_NAME
Type:           kv
Created At:     2025-03-16T02:48:24.437Z
Latest Version: 1
Value:          YOUR_SECRET_VALUE
```

You may also inject secrets into your app as environment variables by passing a command as string, as shown below for an app using python.

```java
hcp vault-secrets run -- python3 my_app.py
```

### Setup / Use HCP API to retrieve your secrets

Generate Service Principal key

An HCP Service Principal and the associated Client_ID and Client_Secret are used for non-human access of HCP APIs from machines, apps, or system services.

Generate credentials <<-- press this button

```java
export HCP_CLIENT_ID=
export HCP_CLIENT_SECRET=
```

View available service principals for your project here. You can learn more about Service Principals and how to use them here.

Generate the API Token

The HCP API requires a valid Access Token. By authenticating to HCP with a user or Service Principal, you can retrieve a short-lived Access Token to call the HCP API.

```java
HCP_API_TOKEN=$(curl --location "https://auth.idp.hashicorp.com/oauth2/token" \
--header "Content-Type: application/x-www-form-urlencoded" \
--data-urlencode "client_id=$HCP_CLIENT_ID" \
--data-urlencode "client_secret=$HCP_CLIENT_SECRET" \
--data-urlencode "grant_type=client_credentials" \
--data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)
```

Read your secrets

```java
curl \
--location "https://api.cloud.hashicorp.com/secrets/2023-11-28/organizations/your-org-ID/projects/your-project-ID/apps/your-app-name/secrets:open" \
--request GET \
--header "Authorization: Bearer $HCP_API_TOKEN" | jq
```

Output

```java
JSON list of all your secrets
```

Test manually

```java
curl -s --location "https://api.cloud.hashicorp.com/secrets/2023-11-28/organizations/your-org-ID/projects/your-project-ID/apps/your-app-name/secrets:open" \
--header "Authorization: Bearer $(curl -s --location "https://auth.idp.hashicorp.com/oauth2/token" \
--header "Content-Type: application/x-www-form-urlencoded" \
--data-urlencode "client_id=your-client-id" \
--data-urlencode "client_secret=your-client-secret" \
--data-urlencode "grant_type=client_credentials" \
--data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)" | jq
```

### Salt commands for HCP Vault

Contents of .env

```java
HCP_SECRETS_URL=https://your-vault-cluster-url
HCP_CLIENT_ID=your-client-id
HCP_CLIENT_SECRET=your-client-secret
```

```java
sudo salt '*' state.apply hashicorp_hcp.install saltenv=dev
sudo salt '*' state.apply hashicorp_hcp.count_secrets saltenv=dev
```


