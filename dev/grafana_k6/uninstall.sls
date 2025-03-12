k6_uninstall:
  pkg.removed:
    - name: k6

k6_cleanup:
  file.absent:
    - name: /etc/k6
