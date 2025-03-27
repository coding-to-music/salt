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

