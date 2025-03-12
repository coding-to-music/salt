grafana_loki_uninstall:
  pkg.removed:
    - pkgs:
      - loki
      - promtail

grafana_loki_cleanup:
  file.absent:
    - name: /etc/loki
    - name: /etc/promtail
