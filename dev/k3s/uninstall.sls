k3s_uninstall:
  cmd.run:
    - name: /usr/local/bin/k3s-uninstall.sh
    - onlyif: test -f /usr/local/bin/k3s-uninstall.sh

k3s_cleanup:
  file.absent:
    - names:
      - /usr/local/bin/k3s
      - /etc/systemd/system/k3s.service
      - /etc/rancher/k3s
