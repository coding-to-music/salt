apache2_upgrade:
  pkg.latest:
    - name: apache2
    - refresh: True

apache2_service_restart:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - pkg: apache2_upgrade
