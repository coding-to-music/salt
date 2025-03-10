apache2_uninstall:
  pkg.removed:
    - name: apache2

apache2_cleanup:
  file.absent:
    - name: /etc/apache2
