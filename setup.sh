#!/usr/bin/env bash
set -euo pipefail

# -- Prompt for system type ─────────────────────────────────────────────────────
arch="$(uname -m)"                            # e.g. arm64 or x86_64
case "$arch" in
  arm64)   nix_arch="aarch64" ;;             # map macOS arm64 -> Nix's aarch64
  x86_64)  nix_arch="x86_64" ;;
  *)       nix_arch="$arch" ;;
esac

os="$(uname -s | tr '[:upper:]' '[:lower:]')" # darwin, linux, etc
default_system_type="${nix_arch}-${os}"
read -p "System Type [${default_system_type}]: " system_type
system_type="${system_type:-$default_system_type}"

# -- Prompt for hostname ───────────────────────────────────────────────────────
if [[ -n "$HOSTNAME" ]]; then
  # remove any domain suffix (e.g. “.local”)
  default_hostname="${HOSTNAME%%.*}"
else
  default_hostname="$(scutil --get ComputerName 2>/dev/null || hostname)"
fi
read -p "Hostname [${default_hostname}]: " hostname
hostname="${hostname:-$default_hostname}"

# -- Prompt for username ───────────────────────────────────────────────────────
default_username="$USER"
read -p "Username [${default_username}]: " username
username="${username:-$default_username}"

# -- Prompt for home directory ──────────────────────────────────────────────────
default_home_directory="$HOME"
read -p "Home Directory [${default_home_directory}]: " home_directory
home_directory="${home_directory:-$default_home_directory}"

# -- Prompt for email & name (with git‐config defaults) ────────────────────────
default_email="$(git config user.email 2>/dev/null)"
read -p "Email [${default_email}]: " email
email="${email:-$default_email}"

# -- Prompt for name (with git‐config defaults) ────────────────────────
default_name="$(git config user.name 2>/dev/null)"
read -p "Name [${default_name}]: " name
name="${name:-$default_name}"

# ─── Generate config ──────────────────────────────────────────────────────────
cat >config.nix <<EOF
{
  systemType     = "${system_type}";     # e.g. aarch64-darwin
  hostname       = "${hostname}";
  username       = "${username}";
  homeDirectory  = "${home_directory}";
  email          = "${email}";
  name           = "${name}";
}
EOF

echo "Config written to ./config.nix"
git update-index --skip-worktree config.nix