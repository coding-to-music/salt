grafana_repo:
  cmd.run:
    - name: |
        wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
        echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
        sudo apt-get update
    - unless: test -f /etc/apt/keyrings/grafana.gpg

alloy_install:
  pkg.installed:
    - name: alloy

alloy_service:
  service.running:
    - name: alloy-server
    - enable: True
    - watch:
      - pkg: alloy_install
