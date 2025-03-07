influxdb_v2_upgrade:
  pkg.latest:
    - name: influxdb
    - version: 2.*
    - refresh: True

influxdb_v2_service_restart:
  service.running:
    - name: influxdb
    - enable: True
    - watch:
      - pkg: influxdb_v2_upgrade
