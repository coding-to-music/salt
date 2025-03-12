grafana_loki_service_stop:
  service.dead:
    - name: loki

promtail_service_stop:
  service.dead:
    - name: promtail
