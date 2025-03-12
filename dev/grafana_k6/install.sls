k6_gpg_key:
  cmd.run:
    - name: |
        sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
    - unless: test -f /usr/share/keyrings/k6-archive-keyring.gpg

k6_repo:
  cmd.run:
    - name: |
        echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
        sudo apt-get update
    - unless: test -f /etc/apt/sources.list.d/k6.list

k6_install:
  pkg.installed:
    - name: k6
