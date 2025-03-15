supabase_ownership:
  file.directory:
    - name: /opt/supabase
    - user: supabase_user
    - group: supabase_user
    - mode: 755
    - recurse:
      - user
      - group
      - mode
