grafana_loki_upgrade:
  pkg.latest:
    - pkgs:
      - loki
      - promtail
    - refresh: True

grafana_loki_service_restart:
  service.running:
    - name: loki
    - enable: True
    - watch:
      - pkg: grafana_loki_upgrade

promtail_service_restart:
  service.running:
    - name: promtail
    - enable: True
    - watch:
      - pkg: grafana_loki_upgrade
