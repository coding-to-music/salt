apache2_repo:
  pkgrepo.managed:
    - humanname: "Apache2 Repository"
    - name: "ppa:ondrej/apache2"
    - file: /etc/apt/sources.list.d/apache2.list

apache2_install:
  pkg.installed:
    - name: apache2

apache2_service:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - pkg: apache2_install
