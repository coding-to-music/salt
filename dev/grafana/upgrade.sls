grafana_upgrade:
  pkg.latest:
    - name: grafana
    - refresh: True

grafana_service_restart:
  service.running:
    - name: grafana-server
    - enable: True
    - watch:
      - pkg: grafana_upgrade
