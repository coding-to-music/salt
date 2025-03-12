grafana_loki_service_start:
  service.running:
    - name: loki
    - enable: True

promtail_service_start:
  service.running:
    - name: promtail
    - enable: True
