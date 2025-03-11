alloy_uninstall:
  pkg.removed:
    - name: alloy

alloy_cleanup:
  file.absent:
    - name: /etc/alloy
