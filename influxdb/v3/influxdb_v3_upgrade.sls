influxdb_v3_upgrade:
  pkg.latest:
    - name: influxdb
    - version: 3.*
    - refresh: True

influxdb_v3_service_restart:
  service.running:
    - name: influxdb
    - enable: True
    - watch:
      - pkg: influxdb_v3_upgrade
