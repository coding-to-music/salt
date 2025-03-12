alloy_upgrade:
  pkg.latest:
    - name: alloy
    - refresh: True

alloy_service_restart:
  service.running:
    - name: alloy-server
    - enable: True
    - watch:
      - pkg: alloy_upgrade
