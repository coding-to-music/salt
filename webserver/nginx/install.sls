nginx_repo:
  pkgrepo.managed:
    - humanname: "Nginx Repository"
    - name: "ppa:nginx/stable"
    - file: /etc/apt/sources.list.d/nginx.list

nginx_install:
  pkg.installed:
    - name: nginx

nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - pkg: nginx_install
