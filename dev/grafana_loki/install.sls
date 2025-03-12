grafana_repo:
  cmd.run:
    - name: |
        wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
        echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
        sudo apt-get update
    - unless: test -f /etc/apt/keyrings/grafana.gpg

grafana_loki_install:
  pkg.installed:
    - pkgs:
      - loki
      - promtail

grafana_loki_service:
  service.running:
    - name: loki
    - enable: True
    - watch:
      - pkg: grafana_loki_install

promtail_service:
  service.running:
    - name: promtail
    - enable: True
    - watch:
      - pkg: grafana_loki_install
