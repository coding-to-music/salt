# Fetch and Display the Number of Secrets in Vault
count_vault_secrets:
  cmd.run:
    - name: |
        set -a && . /srv/salt/.env && set +a && \
        vault kv list secret/ | grep -v "Keys" | wc -l
    - require:
      - pkg: hcp
