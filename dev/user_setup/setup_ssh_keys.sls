{% set username = "newuser" %}
{% set vault_path = "secret/data/ssh_keys" %}

# Create an SSH directory for the user
setup_ssh:
  file.directory:
    - name: /home/{{ username }}/.ssh
    - user: {{ username }}
    - group: {{ username }}
    - mode: 700

# Retrieve the private SSH key from Vault
add_ssh_private_key:
  cmd.run:
    - name: |
        echo "$(vault kv get -field=private_key {{ vault_path }})" > /home/{{ username }}/.ssh/id_rsa
    - user: {{ username }}
    - unless: test -f /home/{{ username }}/.ssh/id_rsa

# Set permissions for the private SSH key
set_ssh_private_key_permissions:
  file.managed:
    - name: /home/{{ username }}/.ssh/id_rsa
    - user: {{ username }}
    - group: {{ username }}
    - mode: 600

# Retrieve the public SSH key from Vault
add_ssh_public_key:
  cmd.run:
    - name: |
        echo "$(vault kv get -field=public_key {{ vault_path }})" > /home/{{ username }}/.ssh/id_rsa.pub
    - user: {{ username }}
    - unless: test -f /home/{{ username }}/.ssh/id_rsa.pub

# Add GitHub to known hosts
github_known_hosts:
  cmd.run:
    - name: ssh-keyscan -t rsa github.com >> /home/{{ username }}/.ssh/known_hosts
    - unless: grep "github.com" /home/{{ username }}/.ssh/known_hosts
    - user: {{ username }}
