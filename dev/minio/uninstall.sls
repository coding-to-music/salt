minio_uninstall:
  pkg.removed:
    - name: minio

minio_cleanup:
  file.absent:
    - names:
      - /usr/local/bin/minio
      - /etc/systemd/system/minio.service
      - /usr/local/minio
