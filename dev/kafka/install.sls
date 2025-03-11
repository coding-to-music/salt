include:
  - java.openjdk-11.install

kafka_repo:
  cmd.run:
    - name: |
        wget -q -O - https://packages.confluent.io/deb/6.2/archive.key | gpg --dearmor | sudo tee /etc/apt/keyrings/kafka.gpg > /dev/null
        echo "deb [signed-by=/etc/apt/keyrings/kafka.gpg] https://packages.confluent.io/deb/6.2 stable main" | sudo tee /etc/apt/sources.list.d/kafka.list
        sudo apt-get update
    - unless: test -f /etc/apt/keyrings/kafka.gpg

kafka_install:
  pkg.installed:
    - name: confluent-platform

kafka_service:
  service.running:
    - name: confluent-server
    - enable: True
    - watch:
      - pkg: kafka_install
