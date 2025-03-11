mongodb_uninstall:
  pkg.removed:
    - name: mongodb-org

mongodb_cleanup:
  file.absent:
    - name: /etc/mongod.conf
