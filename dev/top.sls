dev:
  '*':
    - influxdb.v2.install
    - influxdb.v2.upgrade
    - influxdb.v2.uninstall
    - influxdb.v3.install
    - influxdb.v3.upgrade
    - influxdb.v3.uninstall
    - webserver.apache2.install
    - webserver.apache2.upgrade
    - webserver.apache2.uninstall
    - webserver.nginx.install
    - webserver.nginx.upgrade
    - webserver.nginx.uninstall
    - install_yarn
    - setup_user
    - test
    - timezone
