# /srv/salt/base/install_yarn.sls
install_yarn:
  pkg.installed:
    - name: yarn
