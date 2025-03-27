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

