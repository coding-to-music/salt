kafka_upgrade:
  pkg.latest:
    - name: kafka
    - refresh: True

kafka_service_restart:
  service.running:
    - name: kafka
    - enable: True
    - watch:
      - pkg: kafka_upgrade
