influxdb_v2_uninstall:
  pkg.removed:
    - name: influxdb2

influxdb_v2_cleanup:
  file.absent:
    - name: /etc/influxdb
