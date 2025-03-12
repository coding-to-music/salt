k6_service_start:
  service.running:
    - name: k6
    - enable: True
