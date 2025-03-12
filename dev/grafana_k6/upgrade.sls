k6_upgrade:
  pkg.latest:
    - name: k6
    - refresh: True

k6_service_restart:
  service.running:
    - name: k6
    - enable: True
    - watch:
      - pkg: k6_upgrade
