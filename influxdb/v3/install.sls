influxdb_v3_repo:
  pkgrepo.managed:
    - humanname: "InfluxData Repository"
    - name: "deb https://repos.influxdata.com/debian buster stable"
    - keyid: 2A194991
    - keyserver: keyserver.ubuntu.com
    - dist: buster
    - file: /etc/apt/sources.list.d/influxdb.list

influxdb_v3_install:
  pkg.installed:
    - name: influxdb
    - version: 3.0.1-1

influxdb_v3_service:
  service.running:
    - name: influxdb
    - enable: True
    - watch:
      - pkg: influxdb_v3_install
