include:
  - java.openjdk-11.upgrade

kafka_upgrade:
  pkg.latest:
    - name: confluent-platform
    - refresh: True

kafka_service_restart:
  service.running:
    - name: confluent-server
    - enable: True
    - watch:
      - pkg: kafka_upgrade
