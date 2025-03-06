base:
  '*':
    - test
    - install_yarn
    - setup_user
    - timezone
    - webserver
dev:
  '*':
    - test
    - install_yarn
    - setup_user
    - timezone
