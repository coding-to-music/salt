grafana_uninstall:
  pkg.removed:
    - name: grafana

grafana_cleanup:
  file.absent:
    - name: /etc/grafana
