k3s_upgrade:
  cmd.run:
    - name: curl -sfL https://get.k3s.io | sh -

k3s_service_restart:
  service.running:
    - name: k3s
    - enable: True
    - watch:
      - cmd: k3s_upgrade
