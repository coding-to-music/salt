# Update the apt repository
update_apt:
  cmd.run:
    - name: apt-get update

# Install GPG and coreutils
install_dependencies:
  pkg.installed:
    - pkgs:
      - gpg
      - coreutils
    - require:
      - cmd: update_apt

# Download the HashiCorp GPG key and save it to the keyring
download_gpg_key:
  cmd.run:
    - name: curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    - unless: test -f /usr/share/keyrings/hashicorp-archive-keyring.gpg
    - require:
      - pkg: install_dependencies

# Add the HashiCorp apt repository
add_hashicorp_repo:
  cmd.run:
    - name: echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    - unless: test -f /etc/apt/sources.list.d/hashicorp.list
    - require:
      - cmd: download_gpg_key

# Update the apt repository again after adding the HashiCorp repo
update_apt_after_repo:
  cmd.run:
    - name: apt-get update
    - require:
      - cmd: add_hashicorp_repo

# Install HashiCorp Vault
install_hashicorp_vault:
  pkg.installed:
    - name: hcp
    - require:
      - cmd: update_apt_after_repo

# Ensure required packages are installed
install_dependencies2:
  pkg.installed:
    - pkgs:
      - curl  # For API calls
      - jq    # For processing JSON (optional, but useful)

# Optionally: Clean up previous Vault installations (if needed)
remove_old_vault:
  pkg.purged:
    - name: vault
    - require:
      - pkg: install_dependencies

remove_old_vault_config:
  file.absent:
    - name: /etc/vault.d
    - require:
      - pkg: remove_old_vault
