# salt

## 🚀 Salt Stack formulas for salt-master and salt-minion 🚀

https://github.com/coding-to-music/salt

From / By

## Environment variables

```java

```

## GitHub

```java
git init
git add .
git remote remove origin
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:coding-to-music/salt.git
git push -u origin main
```

## Useful commands

```java
sudo salt-run fileserver.update
sudo salt-run fileserver.file_list
sudo salt-run fileserver.file_list | grep '.sls'

sudo salt-run fileserver.file_list | grep '.sls' | grep java

sudo systemctl restart salt-master
sudo systemctl status salt-master

sudo journalctl -xeu salt-master.service
sudo journalctl -u salt-master
sudo tail -f /var/log/salt/master

sudo systemctl restart salt-minion
sudo systemctl status salt-minion

sudo journalctl -xeu salt-minion.service
sudo journalctl -u salt-minion
sudo tail -n 20 -f /var/log/salt/minion

# view lines that do not begin with # and are not blank lines
grep -v -e '^#' -e '^$' /etc/salt/master
grep -v -e '^#' -e '^$' /etc/salt/minion
```

## accept keys so the master and minions see each other

list accepted keys

```java
sudo salt-key -L
```

remove keys from a minion

```java
sudo salt-key -d minion_name
```

## Applying the States

Apply states from the base environment:

```java
sudo salt '*' state.apply test saltenv=base
sudo salt '*' state.apply vim saltenv=base
sudo salt '*' state.apply timezone saltenv=base
```

Apply states from the dev environment:

```java
sudo salt '*' state.apply influxdb.v2.upgrade saltenv=dev
sudo salt '*' state.apply webserver.apache2.install saltenv=dev
```

## Overall task list

### Server basic setup

- [X] set hostname
- [X] set time zone to NYC
- [ ] remote mount a drive
- [ ] setup drive rsync

### Users

- [X] install ssh keys
- [ ] disable root login
- [X] create user for myself
- [X] .bash_aliases for myself
- [X] sudo for myself
- [X] create user docker
- [X] create user grafana

### cli Software

- [X] github git
- [X] gh github login
- [ ] vercel
- [ ] cloudflare

### systemctl processes

- [X] node-exporter
- [X] grafana alloy
- [ ] ufw firewall
- [X] docker
- [ ] fail2ban

### environment software

- [X] nvm
- [X] node
- [X] yarn
- [X] pnpm
- [ ] deno
- [ ] pyenv
- [X] python3

### Salt-Stack
- [X] Pillars
- [X] Grains
- [X] Hashicorp Vault


### databases & more

- [X] Grafana 
    - [ ] Dashboards
    - [ ] Grafana Auth
    - [ ] Data Sources
    - [ ] Users
- [X] Grafana Loki
- [X] Grafana Tempo
- [X] Grafana Mimir
- [X] Grafana k6
- [ ] Webserver
    - [X] apache2
        - [ ] Demo website
        - [ ] https certificate
        - [ ] Alloy Collector
        - [ ] Grafana Dashboard(s)
    - [X] nginx
        - [ ] Demo website
        - [ ] https certificate
        - [ ] Alloy Collector
        - [ ] Grafana Dashboard(s)
- [ ] MinIO 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [X] influxDB
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [X] postgresql
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] supabase
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] mongoDB
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] kafka
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Redis
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [X] k3s 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [X] Docker 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] GitHub 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Cert Manager via k3s 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Cloudflare DNS 
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Beyla
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)
- [ ] Python Application
    - [ ] CPU Memory Disk Processes Grafana Dashboard(s)
    - [ ] Distribute via apt package
    - [ ] Alloy Collector
    - [ ] Grafana Dashboard(s)

## Salt Terminology - Grains vs Pillars

### Grains

What Are Grains?

- Grains provide static, system-specific information about a Salt minion.
- Examples include OS version, architecture, hostname, IP address, and custom-defined variables (like the hostname you set earlier).

Purpose:

- Grains are useful for categorizing and targeting minions during state execution.
- You can define custom grains to store additional, fixed metadata (e.g., server roles, locations).

How Grains Work:

- They are collected directly from the minion, usually at startup.
- Stored locally on the minion.
- Grains data is accessible throughout a Salt run and doesn't require querying the Salt master.

Examples:

- Default grains: OS, kernel, hostname.
- Custom grains: hostname: server1.

Use Case:

- Target minions based on specific characteristics, e.g., applying states only to Ubuntu servers:

```java
sudo salt -G 'os:Ubuntu' state.apply
```

Key Properties:

- Static or rarely changing.
- Stored on minions (/etc/salt/grains).

### Pillars

What Are Pillars?

- Pillars provide secure, hierarchical data that is assigned from the Salt master to minions.
- Designed for sensitive information, like API keys, passwords, and configurations that shouldn't be hardcoded into states.

Purpose:

- Pillars enable dynamic, customizable data for minions.
- This data is defined and managed centrally on the Salt master.

How Pillars Work:

- Pillars are configured in pillar files on the master (/srv/pillar).
- You can assign data to specific minions or groups of minions via the pillar top file (/srv/pillar/top.sls).
- The master sends pillar data securely to minions during execution.

Examples:

- Storing a database password in a pillar:

```java
db_password: "securepassword123"
```

- Accessing the pillar in a state:

```java
{% set db_pass = salt['pillar.get']('db_password') %}
```

Use Case:

- Distribute secrets or configurations securely, e.g., providing an API key to a specific server.

Key Properties:

- Dynamic and assigned per minion.
- Stored securely on the master.

Comparison
| Feature          | Grains                         | Pillars                              |
|------------------|--------------------------------|--------------------------------------|
| **Purpose**      | Static, system metadata       | Dynamic, secure configuration data   |
| **Location**     | Stored on the minion          | Stored on the master                 |
| **Use**          | Targeting minions and metadata | Distributing secrets/configurations  |
| **Example**      | OS, hostname, IP address      | API keys, passwords, custom configs  |
| **Accessibility**| Automatically available to minion | Assigned securely from the master   |

When to Use Each

- Grains: Use grains for static data that describes the minion itself, such as its location, role, or operating system.  
- Pillars: Use pillars for dynamic, sensitive, or application-specific data that you want to securely distribute from the master.


## Backup hard drive

- [ ] rsync

### Other related repos for setups and installation

https://github.com/coding-to-music/saltstack-salt-in-10-minutes

https://github.com/coding-to-music/setup-linux-server-rsync-data-from-old-server

https://github.com/coding-to-music/install-virtualbox-on-digitalocean-or-contabo

https://github.com/coding-to-music/using-fail2ban-to-harden-linux-server

## k3s

https://docs.k3s.io/installation

https://computingforgeeks.com/installing-k3s-on-ubuntu-noble-numbat/

https://docs.k3s.io/installation/requirements?os=debian

Manual Install

```java
```

Salt commands for k3s

```java
sudo salt '*' state.apply k3s.install saltenv=dev

sudo salt '*' state.apply k3s.uninstall saltenv=dev

sudo salt '*' state.apply k3s.upgrade saltenv=dev

sudo salt '*' state.apply k3s.start saltenv=dev

sudo salt '*' state.apply k3s.stop saltenv=dev
```


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


## Create User

```java
sudo salt '*' state.apply user_setup.create_user saltenv=dev
sudo salt '*' state.apply user_setup.get_bash_files saltenv=dev
sudo salt '*' state.apply user_setup.setup_ssh_keys saltenv=dev
sudo salt '*' state.apply user_setup.setup_github saltenv=dev
```

## Redis

https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/

Manual Install

```java
sudo apt-get install lsb-release curl gpg
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install redis
```

Redis will start automatically, and it should restart at boot time. If Redis doesn't start across reboots, you may need to manually enable it:

```java
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

Connect to Redis
Once Redis is running, you can test it by running redis-cli:

redis-cli
Test the connection with the ping command:

127.0.0.1:6379> ping
PONG

https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/#install-redis-properly

https://redis.io/docs/latest/develop/tools/cli/

https://redis.io/docs/latest/develop/clients/

https://redis.io/docs/latest/develop/tools/insight/

https://redis.io/docs/latest/operate/redisinsight/install/

Salt commands for Redis

```java
sudo salt '*' state.apply redis.install saltenv=dev

sudo salt '*' state.apply redis.uninstall saltenv=dev

sudo salt '*' state.apply redis.upgrade saltenv=dev

sudo salt '*' state.apply redis.start saltenv=dev

sudo salt '*' state.apply redis.stop saltenv=dev
```

## non-root-user - Node Yarn pmpm 

Salt commands for non-root-user for Node Yarn pnpm

```java
sudo salt '*' state.apply non_root_node_yarn_pnpm.install saltenv=dev

sudo salt '*' state.apply non_root_node_yarn_pnpm.upgrade saltenv=dev
```

## root-user - Node Yarn pmpm 

Salt commands for root-user for Node Yarn pnpm

```java
sudo salt '*' state.apply root_node_yarn_pnpm.install saltenv=dev

sudo salt '*' state.apply root_node_yarn_pnpm.upgrade saltenv=dev
```

## Grafana MLTP - Metrics, Logs, Traces and Profiles

https://grafana.com/docs/loki/latest/setup/install/local/

Manual Install

https://github.com/grafana/intro-to-mltp


Salt commands for Grafana mltp

- init.sls: Installs dependencies and sets up the initial environment.
- update.sls: Fetches the latest files and updates the running containers.
- files/: Optional directory for Jinja-templated files (if customization is needed).

```java
sudo salt '*' state.apply grafana_mltp.init saltenv=dev

sudo salt '*' state.apply grafana_mltp.install saltenv=dev

sudo salt '*' state.apply grafana_mltp.uninstall saltenv=dev

sudo salt '*' state.apply grafana_mltp.upgrade saltenv=dev

sudo salt '*' state.apply grafana_mltp.start saltenv=dev

sudo salt '*' state.apply grafana_mltp.stop saltenv=dev
```

### Verification

Check that containers are running:

```java
salt 'your-minion-id' cmd.run 'docker ps'
```

### Customization (Optional)

If you need to modify the docker-compose.yml (e.g., change ports or environment variables), you can:

Use a Jinja Template:

Create /srv/salt/grafana-mltp/files/docker-compose.yml.jinja and fetch the raw file as a base, then customize it. For example:

```java
# /srv/salt/grafana-mltp/update.sls (modified snippet)
fetch_docker_compose_base:
  cmd.run:
    - name: curl -s -L https://raw.githubusercontent.com/grafana/intro-to-mltp/main/docker-compose.yml -o /tmp/docker-compose.yml.base
    - require:
        - file: grafana_mltp_dir

render_docker_compose:
  file.managed:
    - name: /opt/grafana-mltp/docker-compose.yml
    - source: salt://grafana-mltp/files/docker-compose.yml.jinja
    - template: jinja
    - context:
        base_content: {{ salt['cmd.run']('cat /tmp/docker-compose.yml.base') | yaml_encode }}
    - require:
        - cmd: fetch_docker_compose_base
```

In docker-compose.yml.jinja, you could append or modify sections:

```java
{{ base_content }}

# Add custom overrides here if needed
```

Pillar Data: Use Salt pillar to pass variables (e.g., `pillar['grafana_mltp']['port']`) for dynamic configuration.


### Automate Updates

To keep the environment updated, you can:

Schedule the Update State: Use Salt’s scheduler to run update.sls periodically.

Add this to your minion’s config (/etc/salt/minion or via pillar):

```java
schedule:
  update_grafana_mltp:
    function: state.apply
    args:
      - grafana-mltp.update
    minutes: 60  # Runs hourly; adjust as needed
```

Restart the minion:

```java
salt 'your-minion-id' service.restart salt-minion
```

Highstate Integration: Include both states in a top file (/srv/salt/top.sls):

```java
base:
  'your-minion-id':
    - grafana-mltp
    - grafana-mltp.update
```

Apply with:

```java
salt 'your-minion-id' state.highstate
```



## Supabase

https://supabase.com/docs/guides/self-hosting

https://supabase.com/docs/guides/local-development/cli/getting-started?queryGroups=platform&platform=linux

https://supabase.com/docs/guides/local-development?queryGroups=package-manager&package-manager=yarn

### Manual Supabase install

https://supabase.com/docs/guides/self-hosting/docker

Installing and running Supabase

Follow these steps to start Supabase on your machine:

```java
# Get the code
git clone --depth 1 https://github.com/supabase/supabase

# Go to the docker folder
cd supabase/docker

# Copy the fake env vars
cp .env.example .env

# Pull the latest images
docker compose pull

# Start the services (in detached mode)
docker compose up -d
```

Note: If you are using rootless docker, edit `.env` and set `DOCKER_SOCKET_LOCATION` to your docker socket location. For example: `/run/user/1000/docker.sock` Otherwise, you will see an error like `container supabase-vector exited (0)`

After all the services have started you can see them running in the background:

```java
docker compose ps
```

All of the services should have a status running (healthy). If you see a status like created but not running, try starting that service manually with docker compose start <service-name>.

Your app is now running with default credentials.

Secure your services as soon as possible using the instructions below.

Accessing Supabase Studio#

You can access Supabase Studio through the API gateway on port `8000`. For example: `http://<your-ip>:8000`, or `localhost:8000` if you are running Docker locally.

You will be prompted for a username and password. By default, the credentials are:

```java
Username: supabase
Password: this_password_is_insecure_and_should_be_updated
```

You should change these credentials as soon as possible using the instructions below.

Accessing the APIs

Each of the APIs are available through the same API gateway:

- REST: http://<your-ip>:8000/rest/v1/
- Auth: http://<your-domain>:8000/auth/v1/
- Storage: http://<your-domain>:8000/storage/v1/
- Realtime: http://<your-domain>:8000/realtime/v1/

Accessing your Edge Functions

- Edge Functions are stored in `volumes/functions`. The default setup has a hello Function that you can invoke on `http://<your-domain>:8000/functions/v1/hello`
- You can add new Functions as `volumes/functions/<FUNCTION_NAME>/index.ts`. Restart the functions service to pick up the changes: `docker compose restart functions --no-deps`

Accessing Postgres

- By default, the Supabase stack runs the Supavisor connection pooler. Supavisor provides efficient management of database connections.

You can connect to the Postgres database using the following methods:

For session-based connections (equivalent to direct Postgres connections):

```java
psql 'postgres://postgres.your-tenant-id:your-super-secret-and-long-postgres-password@localhost:5432/postgres'
```

For pooled transactional connections:

```java
psql 'postgres://postgres.your-tenant-id:your-super-secret-and-long-postgres-password@localhost:6543/postgres'
```

The default tenant ID is `your-tenant-id`, and the default password is `your-super-secret-and-long-postgres-password`. You should change these as soon as possible using the instructions below.

By default, the database is not accessible from outside the local machine but the pooler is. You can change this by updating the docker-compose.yml file.

Updating your services

For security reasons, we "pin" the versions of each service in the docker-compose file (these versions are updated ~monthly). If you want to update any services immediately, you can do so by updating the version number in the docker compose file and then running docker compose pull. You can find all the latest docker images in the Supabase Docker Hub.

You should update your services frequently to get the latest features and bug fixes and security patches. Note that you will need to restart the services to pick up the changes, which will result in some downtime for your services.

Example

You'll want to update the Studio(Dashboard) frequently to get the latest features and bug fixes. To update the Dashboard:

- Visit the supabase/studio image in the Supabase Docker Hub
- Find the latest version (tag) number. It will look something like `20241029-46e1e40`
- Update the image field in the `docker-compose.yml` file to the new version. It should look like this: `image: supabase/studio:20241028-a265374`
- Run docker compose pull and then `docker compose up -d` to restart the service with the new version.

Securing your services#

While we provided you with some example secrets for getting started, you should NEVER deploy your Supabase setup using the defaults we have provided. Follow all of the steps in this section to ensure you have a secure setup, and then restart all services to pick up the changes.


Environment Variables in `.env`:

Secrets like `POSTGRES_PASSWORD` and `GOTRUE_JWT_SECRET` are extracted from the API response and written to `/opt/supabase/.env`

Define these secrets in https://portal.cloud.hashicorp.com/

```java
POSTGRES_PASSWORD 
GOTRUE_JWT_SECRET
```

### .env Configuration: Make sure `/srv/salt/.env` includes the following variables:

```java
BAD_HCP_SECRETS_URL=https://api.cloud.hashicorp.com/secrets/2023-11-28/organizations/your-org-ID/projects/your-project-ID/apps/your-app-name/secrets:open

HCP_SECRETS_URL=https://api.cloud.hashicorp.com/secrets/2023-06-13/organizations/$HCP_ORG_ID/projects/$HCP_PROJECT_ID/apps/$VLT_APPS_NAME/open
HCP_CLIENT_ID=your-client-id
HCP_CLIENT_SECRET=your-client-secret
```

Salt commands for Supabase

```java
# do these first once just to setup supabase_user in linux and install docker and docker-compose
sudo salt '*' state.apply supabase.docker_install saltenv=dev
sudo salt '*' state.apply supabase.create_user saltenv=dev
sudo salt '*' state.apply supabase.ownership saltenv=dev
```

To download the docker images, you need to log into docker hub

```java
sudo docker login
```

# optionally clear the log for easier post-run viewing
rm /var/log/supabase_config_using_hcp_secrets.log

# then this gets called as often as needed to install and configure supabase using docker
sudo salt '*' state.apply supabase.supabase_docker_setup saltenv=dev
```

View the log and .env 

```java
cat /var/log/supabase_config_using_hcp_secrets.log

cat /opt/supabase/.env
```

Apply the State: Apply the updated state using:

```java
sudo salt '*' state.apply supabase.docker_setup saltenv=dev
```

Verify Secrets: Ensure /opt/supabase/.env contains the fetched secrets:

```java
cat /opt/supabase/.env
```

Check Services: Verify that the Supabase services are running:

```java
docker ps
```

Automated Updates: Use the update state to refresh Docker images and restart Supabase monthly:

```java
sudo salt '*' state.apply supabase.supabase_update saltenv=dev
```

Optional: Schedule Updates

To automate monthly updates, you can add a Salt schedule or a cron job:

Add a Cron Job for Updates:

```java
sudo crontab -e
```

Add this line to execute the update state monthly:

```java
0 2 1 * * salt '*' state.apply supabase.supabase_update saltenv=dev
```

## Grafana Cloud integration for Supabase cloud supabase

### To set up a Service Role API Key for your Supabase project, follow these steps:

- Log in to Supabase:
- Go to the Supabase website and log in to your account.
- Select Your Project:
- From your dashboard, select the project for which you want to create the Service Role API Key.
- Go to Project Settings at the bottom of the Left Sidebar
- Click on API Settings
- https://supabase.com/dashboard/project/{project-id}/settings/api

Navigate to API Settings:

- In the left sidebar, click on "Settings."
- Then, click on "API" under the settings menu.
- Locate the Service Role API Key:

In the API settings, you will find the "API Keys" section.
- Here, you will see the "Service Role" key listed. This key has elevated permissions and should be kept secure.
- Copy the Service Role API Key:
- Click on the copy icon next to the Service Role API Key to copy it to your clipboard.

Use the Key in Cloud Grafana:

Now that you have the Service Role API Key, you can use it in your Cloud Grafana setup to scrape metrics from Supabase.

Important Note: The Service Role API Key has full access to your database, so make sure to keep it secure and do not expose it in client-side code or public repositories.

To configure authentication for your Prometheus-Supabase data source using your SUPABASE_SERVICE_ROLE_API_KEY, follow these steps:
- Set the Prometheus Server URL like this: https://<project-ref>.supabase.co/customer/v1/privileged/metrics`, where `project-ref` is your `project ID`
- Go to Connections in the left-side menu
- Find your prometheus-supabase data source and click on it to edit
- Scroll down to the Authentication section
- Select Basic authentication from the dropdown menu
- For the username, enter `service_role`
- For the password, enter your `SUPABASE_SERVICE_ROLE_API_KEY`
- Click Save & test at the bottom of the page to verify the connection


To set up the Supabase integration as a data source in Grafana, you need to follow these steps:

- Log in to your Grafana Cloud account.
- Navigate to the Connections section by clicking on Connections in the left-side menu.
- Search for "Supabase" in the search bar or browse through the available integrations.
- Click on the Supabase integration tile.
- Click on Add new data source or the equivalent button to create a new Supabase connection.

The Supabase integration includes a pre-built dashboard that gives you a comprehensive overview of Supabase performance metrics, supplemented with PostgreSQL metrics Supabase integration for Grafana Cloud.

If you're using the Metrics Endpoint solution for Supabase, you'll need:

- The URL and path to your Supabase project's metrics
- Basic authentication credentials to access those metrics

For the Metrics Endpoint setup specifically:

Your Scrape URL will be `https://<project-ref>.supabase.co/customer/v1/privileged/metrics`, where `project-ref` is your `project ID`


Your Basic Auth username will be service_role and your password will be your service_role key Introducing agentless monitoring for Prometheus in Grafana Cloud

After configuring the data source, you can save and test your connection, and then use the pre-built dashboard to visualize your Supabase metrics.

This worked

```java
curl -s -u "service_role:YOUR_SERVICE_ROLE_API_KEY" "https://<project-ref>.supabase.co/customer/v1/privileged/metrics"
```

### The supplied Integration - Supabase -> Supabase Project Dashboard does not have a functioning Project variable

To fix / replace the `Project` variable
- Go to the Variables tab
- If you see the existing "project" variable, you can edit it, or create a new one by clicking + New variable
- Configure the variable with these settings:
  - Name: project
  - Type: Query
  - Data source: Select your Supabase Prometheus data source
  - Query: `label_values(supabase_project_ref)` (This query fetches all available Supabase project references)
  - Refresh: On dashboard load
  - Sort: Alphabetical (or your preference)
  - Click Update or Add to save the variable

This approach is similar to how variables are set up for other data sources in Grafana, as documented in the Prometheus template variables guide.

## Grafana integration for self-hosted Supabase

- 1. Project Reference ID

Since you're self-hosting, you won't have a Supabase-hosted project URL like `https://<project-reference-id>.supabase.co` 

Instead:

The Project Reference ID is typically a unique identifier for your Supabase project. If you're using the Supabase CLI or have configured your project locally, you can find it in the supabase/config.toml file. Look for a field like project_id or project_ref.

If you don't see it there, you might need to define a custom identifier for your self-hosted setup to integrate with Grafana.

- 2. Service Role API Key

For self-hosted Supabase, the Service Role API Key is generated during the setup process. Here's how you can retrieve or generate it:

Check your `.env` file or the environment variables used in your Docker Compose setup. Look for a variable like `SUPABASE_SERVICE_ROLE_KEY`

If it's not present, you may need to generate a new key manually. This key is typically tied to your Postgres database and should have elevated privileges to bypass Row Level Security (RLS).

- 3. Integration with Grafana

Once you have both the Project Reference ID and the Service Role API Key, you can configure Grafana to scrape metrics from your self-hosted Supabase instance. Ensure that:

Your Supabase instance exposes the necessary metrics endpoint.

Grafana is configured with the correct credentials and endpoint URL.

## MongoDB

https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/

Manual Install

```java
# Import the public key
sudo apt-get install gnupg curl

curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

# Create the list file.
# Create the list file /etc/apt/sources.list.d/mongodb-org-8.0.list for your version of Ubuntu.
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list   

sudo apt-get update

sudo apt-get install -y mongodb-org

# check version
mongod --version
```

https://www.mongodb.com/docs/manual/tutorial/getting-started/#std-label-getting-started

https://www.mongodb.com/docs/mongodb-shell/

https://idroot.us/install-mongodb-ubuntu-24-04/

https://www.cherryservers.com/blog/install-mongodb-ubuntu-2404#step-6-create-mongodb-admin-user

https://www.cherryservers.com/blog/install-mongodb-ubuntu-2404#step-7-securing-mongodb

Salt commands for MongoDB

```java
sudo salt '*' state.apply mongodb.install saltenv=dev

sudo salt '*' state.apply mongodb.uninstall saltenv=dev

sudo salt '*' state.apply mongodb.upgrade saltenv=dev

sudo salt '*' state.apply mongodb.start saltenv=dev

sudo salt '*' state.apply mongodb.stop saltenv=dev
```

## Grafana

Manual Grafana Install

https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/

```java
# Import the GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add a repository for stable releases
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Updates the list of available packages
sudo apt-get update

# Installs the latest OSS release:
sudo apt-get install grafana
```

Salt commands for Grafana

```java
sudo salt '*' state.apply grafana.install saltenv=dev

sudo salt '*' state.apply grafana.uninstall saltenv=dev

sudo salt '*' state.apply grafana.upgrade saltenv=dev

sudo salt '*' state.apply grafana.start saltenv=dev

sudo salt '*' state.apply grafana.stop saltenv=dev
```

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

## Grafana K6

https://grafana.com/docs/k6/latest/set-up/install-k6/#linux

Manual K6 Install

```java
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

Runs as an executable when you want to load test, does not run as a service, thus there is no start and stop sls files

Salt commands for K6

```java
sudo salt '*' state.apply grafana_k6.install saltenv=dev

sudo salt '*' state.apply grafana_k6.uninstall saltenv=dev

sudo salt '*' state.apply grafana_k6.upgrade saltenv=dev
```

## Grafana Loki

https://grafana.com/docs/loki/latest/setup/install/local/

Manual Loki Install

```java
apt-get update
apt-get install loki promtail
```

Salt commands for Loki

```java
sudo salt '*' state.apply grafana_loki.install saltenv=dev

sudo salt '*' state.apply grafana_loki.uninstall saltenv=dev

sudo salt '*' state.apply grafana_loki.upgrade saltenv=dev

sudo salt '*' state.apply grafana_loki.start saltenv=dev

sudo salt '*' state.apply grafana_loki.stop saltenv=dev
```

## Grafana Mimir

https://grafana.com/docs/mimir/latest/get-started/

Manual Mimir Install


Salt commands for Mimir

```java
sudo salt '*' state.apply grafana_mimir.install saltenv=dev

sudo salt '*' state.apply grafana_mimir.uninstall saltenv=dev

sudo salt '*' state.apply grafana_mimir.upgrade saltenv=dev

sudo salt '*' state.apply grafana_mimir.start saltenv=dev

sudo salt '*' state.apply grafana_mimir.stop saltenv=dev
```

## Grafana Tempo

https://grafana.com/docs/tempo/latest/setup/linux/

Manual Tempo Install


Salt commands for Tempo

```java
sudo salt '*' state.apply grafana_tempo.install saltenv=dev

sudo salt '*' state.apply grafana_tempo.uninstall saltenv=dev

sudo salt '*' state.apply grafana_tempo.upgrade saltenv=dev

sudo salt '*' state.apply grafana_tempo.start saltenv=dev

sudo salt '*' state.apply grafana_tempo.stop saltenv=dev
```

## InfluxDB

Add the GPG Key for InfluxDB, Download the GPG Key:

These instructions are specific for Ubuntu 24

https://docs.influxdata.com/influxdb/v2/install/?t=Linux

```java
# Clean up any existing keyring files and repository configurations to avoid conflicts
sudo rm -f /usr/share/keyrings/influxdb-archive-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/influxdb.list

# Ubuntu and Debian

# Add the InfluxData key to verify downloads and add the repository
curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key
echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum --check - && cat influxdata-archive.key \
| gpg --dearmor \
| tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| tee /etc/apt/sources.list.d/influxdata.list

# Install influxdb
# sudo apt-get update && sudo apt-get install influxdb2

# Update the package lists to apply the changes
sudo apt-get update

```

Salt commands for InfluxDB V2

```java
sudo salt '*' state.apply influxdb.v2.install saltenv=dev

sudo salt '*' state.apply influxdb.v2.upgrade saltenv=dev

sudo service influxdb status
```

Salt commands for InfluxDB V3

```java
sudo salt '*' state.apply influxdb.v3.install saltenv=dev

sudo salt '*' state.apply influxdb.v3.upgrade saltenv=dev

sudo service influxdb status
```

## Webserver apache2 and nginx

Salt commands for Apache2:

```java
sudo salt '*' state.apply webserver.apache2.install saltenv=dev

sudo salt '*' state.apply webserver.apache2.uninstall saltenv=dev

sudo salt '*' state.apply webserver.apache2.upgrade saltenv=dev
```

Salt commands for Nginx:

```java
sudo salt '*' state.apply webserver.nginx.install saltenv=dev

sudo salt '*' state.apply webserver.nginx.uninstall saltenv=dev

sudo salt '*' state.apply webserver.nginx.upgrade saltenv=dev
```

## MinIO

Manual Install

```java
sudo salt '*' state.apply minio.install saltenv=dev

sudo salt '*' state.apply minio.uninstall saltenv=dev

sudo salt '*' state.apply minio.upgrade saltenv=dev

sudo salt '*' state.apply minio.start saltenv=dev

sudo salt '*' state.apply minio.stop saltenv=dev
```

## Java

Manual Install

```java
```

Salt commands for Java

```java
sudo salt '*' state.apply java.openjdk-11.install saltenv=dev

sudo salt '*' state.apply java.openjdk-11.upgrade saltenv=dev
```

## Kafka

Manual Install

```java
```

Salt commands for Kafka

```java
sudo salt '*' state.apply kafka.install saltenv=dev

sudo salt '*' state.apply kafka.uninstall saltenv=dev

sudo salt '*' state.apply kafka.upgrade saltenv=dev

sudo salt '*' state.apply kafka.start saltenv=dev

sudo salt '*' state.apply kafka.stop saltenv=dev
```

Validate

```java
systemctl status confluent-server
```

## Python Application

Manual Install

```java
```

