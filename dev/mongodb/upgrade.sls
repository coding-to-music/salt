mongodb_upgrade:
  pkg.latest:
    - name: mongodb-org
    - refresh: True

mongodb_service_restart:
  service.running:
    - name: mongod
    - enable: True
    - watch:
      - pkg: mongodb_upgrade
