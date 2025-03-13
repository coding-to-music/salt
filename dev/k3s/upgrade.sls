k3s_upgrade:
  cmd.run:
    - name: |
        curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-backend=none" sh -
    - require:
      - cmd: k3s_install

k3s_service_restart:
  service.running:
    - name: k3s
    - enable: True
    - watch:
      - cmd: k3s_upgrade
