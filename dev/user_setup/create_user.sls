{% set username = "newuser" %}
{% set vault_path = "secret/data/github" %}

# Create user
{{ username }}_user:
  user.present:
    - name: {{ username }}
    - home: /home/{{ username }}
    - shell: /bin/bash
    - createhome: True

# Add user to sudo group
{{ username }}_sudo:
  user.present:
    - name: {{ username }}
    - groups:
      - sudo
    - append: True

# Set password for the user using a HashiCorp Vault secret
{{ username }}_set_password:
  cmd.run:
    - name: echo "{{ username }}:$(vault kv get -field=password {{ vault_path }})" | chpasswd
    - unless: id {{ username }}
