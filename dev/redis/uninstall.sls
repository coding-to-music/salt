redis_uninstall:
  pkg.removed:
    - name: redis

redis_cleanup:
  file.absent:
    - name: /etc/redis
