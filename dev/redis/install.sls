redis_gpg_key:
  cmd.run:
    - name: |
        curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
        sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
    - unless: test -f /usr/share/keyrings/redis-archive-keyring.gpg

redis_repo:
  cmd.run:
    - name: |
        echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
        sudo apt-get update
    - unless: test -f /etc/apt/sources.list.d/redis.list

redis_install:
  pkg.installed:
    - name: redis

redis_service:
  service.running:
    - name: redis-server
    - enable: True
    - watch:
      - pkg: redis_install
