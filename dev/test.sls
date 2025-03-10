# /srv/salt/base/test.sls
test:
  cmd.run:
    - name: echo "Test state executed"
