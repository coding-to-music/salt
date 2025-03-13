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
    - unless: test -f /usr/local/bin/minio

minio_service_file:
  file.managed:
    - name: /etc/systemd/system/minio.service
    - source: salt://minio/minio.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: minio_install

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
      - file: minio_service_file
      - file: minio_data_dir
