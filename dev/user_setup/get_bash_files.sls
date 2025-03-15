{% set username = "newuser" %}
{% set github_repo = "git@github.com:your_username/your_private_repo.git" %}

# Clone the private GitHub repository
clone_repo:
  git.latest:
    - name: {{ github_repo }}
    - target: /home/{{ username }}/repo
    - user: {{ username }}
    - identity: /home/{{ username }}/.ssh/id_rsa
    - require:
      - cmd: github_known_hosts

# Copy `.bashrc` to the user's home directory
copy_bashrc:
  file.managed:
    - source: salt://user_setup/repo/.bashrc
    - name: /home/{{ username }}/.bashrc
    - user: {{ username }}
    - group: {{ username }}
    - mode: 644
    - require:
      - git: clone_repo

# Copy `.bash_aliases` to the user's home directory
copy_bash_aliases:
  file.managed:
    - source: salt://user_setup/repo/.bash_aliases
    - name: /home/{{ username }}/.bash_aliases
    - user: {{ username }}
    - group: {{ username }}
    - mode: 644
    - require:
      - git: clone_repo
