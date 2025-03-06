# saltstack-repo/pillar/top.sls
base:
  '*':
    - user_pillars
