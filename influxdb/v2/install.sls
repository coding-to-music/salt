influxdb_v2_repo:
  pkgrepo.managed:
    - humanname: "InfluxData Repository"
    - name: "deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/ubuntu stable main"
    - file: /etc/apt/sources.list.d/influxdata.list

influxdb_v2_key:
  cmd.run:
    - name: "curl --silent --location -O https://repos.influxdata.com/influxdata-archive.key && echo '943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515 influxdata-archive.key' | sha256sum --check - && cat influxdata-archive.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null"
    - unless: "test -f /etc/apt/trusted.gpg.d/influxdata-archive.gpg"

influxdb_v2_install:
  pkg.installed:
    - name: influxdb2

influxdb_v2_service:
  service.running:
    - name: influxdb
    - enable: True
    - watch:
      - pkg: influxdb_v2_install
