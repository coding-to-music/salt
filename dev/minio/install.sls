minio_user:
  user.present:
    - name: minio
    - home: /usr/local/minio
    - shell: /bin/bash

minio_group:
  group.present:
    - name: minio

minio_install:
  cmd.run:
    - name: |
        wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
        chmod +x /usr/local/bin/minio
        wget https://dl.min.io/server/minio/release/linux-amd64/minio.service -O /etc/systemd/system/minio.service
    - unless: test -f /usr/local/bin/minio

minio_data_dir:
  file.directory:
    - name: /usr/local/minio
    - user: minio
    - group: minio
    - mode: 755
    - require:
      - user: minio_user
      - cmd: minio_install

minio_service:
  service.running:
    - name: minio
    - enable: True
    - watch:
      - cmd: minio_install
      - file: minio_data_dir
