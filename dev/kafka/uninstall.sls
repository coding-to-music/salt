kafka_uninstall:
  pkg.removed:
    - name: confluent-platform

kafka_cleanup:
  file.absent:
    - name: /etc/kafka
