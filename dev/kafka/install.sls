kafka_repo:
  pkgrepo.managed:
    - humanname: "Apache Kafka Repository"
    - name: "http://your-repository-url"
    - keyid: "your-key-id"
    - keyserver: "your-keyserver-url"
    - file: /etc/apt/sources.list.d/kafka.list

kafka_install:
  pkg.installed:
    - name: kafka

kafka_service:
  service.running:
    - name: kafka
    - enable: True
    - watch:
      - pkg: kafka_install
