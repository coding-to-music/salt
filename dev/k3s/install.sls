k3s_install:
  cmd.run:
    - name: |
        curl -sfL https://get.k3s.io | sh -
    - unless: test -f /usr/local/bin/k3s

k3s_service:
  service.running:
    - name: k3s
    - enable: True
    - watch:
      - cmd: k3s_install
