minio_upgrade:
  cmd.run:
    - name: |
        wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
        chmod +x /usr/local/bin/minio
    - require:
      - cmd: minio_install

minio_service_restart:
  service.running:
    - name: minio
    - enable: True
    - watch:
      - cmd: minio_upgrade
