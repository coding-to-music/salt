influxdb_v2_repo:
  pkgrepo.managed:
    - humanname: "InfluxData Repository"
    - name: "deb https://repos.influxdata.com/debian buster stable"
    - keyid: 2A194991
    - keyserver: keyserver.ubuntu.com
    - dist: buster
    - file: /etc/apt/sources.list.d/influxdb.list

influxdb_v2_install:
  pkg.installed:
    - name: influxdb
    - version: 2.0.9-1

influxdb_v2_service:
  service.running:
    - name: influxdb
    - enable: True
    - watch:
      - pkg: influxdb_v2_install
