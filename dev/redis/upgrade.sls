redis_upgrade:
  pkg.latest:
    - name: redis
    - refresh: True

redis_service_restart:
  service.running:
    - name: redis-server
    - enable: True
    - watch:
      - pkg: redis_upgrade
