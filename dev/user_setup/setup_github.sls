{% set username = "newuser" %}
{% set vault_path = "secret/data/github" %}

# Install Git if not already present
install_git:
  pkg.installed:
    - name: git

# Create an SSH directory for GitHub authentication
setup_ssh:
  file.directory:
    - name: /home/{{ username }}/.ssh
    - user: {{ username }}
    - group: {{ username }}
    - mode: 700

# Add the SSH private key from Vault
add_ssh_key:
  file.managed:
    - name: /home/{{ username }}/.ssh/id_rsa
    - contents_pillar: {{ vault_path }}:private_key
    - user: {{ username }}
    - group: {{ username }}
    - mode: 600

# Add GitHub to known hosts
github_known_hosts:
  cmd.run:
    - name: ssh-keyscan -t rsa github.com >> /home/{{ username }}/.ssh/known_hosts
    - unless: grep "github.com" /home/{{ username }}/.ssh/known_hosts
    - user: {{ username }}
