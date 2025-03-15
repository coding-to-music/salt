base:
  '*':
    - user_setup.create_user
    - user_setup.setup_ssh_keys
    - user_setup.setup_github
    - user_setup.get_bash_files
