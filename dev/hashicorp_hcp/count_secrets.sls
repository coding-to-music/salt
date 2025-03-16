# Count the secrets in HCP Vault
count_hcp_secrets:
  cmd.run:
    - name: |
        curl -s -X GET https://<vault-cluster-url>/v1/secret/ \
        -H "Authorization: Bearer $(cat /srv/salt/hashicorp_hcp/.env)" | jq '.data | length'
    - require:
      - cmd: store_token_in_env
