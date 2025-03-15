supabase_user:
  user.present:
    - name: supabase_user
    - home: /home/supabase_user
    - shell: /bin/bash
    - createhome: True
    - groups:
      - docker
