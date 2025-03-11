redis_service_start:
  service.running:
    - name: redis-server
    - enable: True
