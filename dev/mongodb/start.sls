mongodb_service_start:
  service.running:
    - name: mongod
    - enable: True
