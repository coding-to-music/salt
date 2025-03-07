nginx_uninstall:
  pkg.removed:
    - name: nginx

nginx_cleanup:
  file.absent:
    - name: /etc/nginx
