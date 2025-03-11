mongodb_gpg_key:
  cmd.run:
    - name: |
        curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
    - unless: test -f /usr/share/keyrings/mongodb-server-8.0.gpg

mongodb_repo:
  cmd.run:
    - name: |
        echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
        sudo apt-get update
    - unless: test -f /etc/apt/sources.list.d/mongodb-org-8.0.list

mongodb_install:
  pkg.installed:
    - name: mongodb-org

mongodb_service:
  service.running:
    - name: mongod
    - enable: True
    - watch:
      - pkg: mongodb_install
