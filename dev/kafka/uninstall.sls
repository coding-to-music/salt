kafka_uninstall:
  pkg.removed:
    - name: kafka

kafka_cleanup:
  file.absent:
    - name: /etc/kafka
