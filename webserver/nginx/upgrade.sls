nginx_upgrade:
  pkg.latest:
    - name: nginx
    - refresh: True

nginx_service_restart:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - pkg: nginx_upgrade
