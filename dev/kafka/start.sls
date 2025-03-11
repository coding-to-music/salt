kafka_service_start:
  service.running:
    - name: confluent-kafka
    - enable: True
