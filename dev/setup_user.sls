create_user:
  user.present:
    - name: {{ pillar['username'] }}
    - shell: /bin/bash
    - home: /home/{{ pillar['username'] }}

fetch_github_keys:
  cmd.run:
    - name: |
        mkdir -p /home/{{ pillar['username'] }}/.ssh &&
        curl -s https://github.com/{{ pillar['github_account'] }}.keys > /home/{{ pillar['username'] }}/.ssh/authorized_keys &&
        chown -R {{ pillar['username'] }}:{{ pillar['username'] }} /home/{{ pillar['username'] }}/.ssh &&
        chmod 700 /home/{{ pillar['username'] }}/.ssh &&
        chmod 600 /home/{{ pillar['username'] }}/.ssh/authorized_keys
    - user: {{ pillar['username'] }}
