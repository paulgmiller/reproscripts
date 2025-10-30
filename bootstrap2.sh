#!/usr/bin/env bash
set -euo pipefail

# Simple, opinionated Ubuntu/WSL bootstrap
# - no optional flags
# - installs: base tools, Docker, Go, gh, Azure CLI, kubectl, kubectl aliases
# - configures git for Azure DevOps (your org)
# - installs git-credential-azure
# - installs azgoproxycreds
# - appends your AKS/GOPROXY env to ~/.bashrc
#
# Assumptions:
# - running as a normal user with sudo
# - Ubuntu or Ubuntu-on-WSL
# - you want Docker *inside* this Ubuntu, not via Windows Docker Desktop
# - you're okay with `newgrp docker` at the end

GIT_USER_NAME="Paul Miller"
GIT_USER_EMAIL="pmiller@microsoft.com"

# detect ubuntu codename
UBUNTU_CODENAME=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")

echo "[1/10] apt update + base deps"
sudo apt-get update
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  make \
  jq \
  git \
  unzip \
  build-essential

echo "[2/10] install Go (like your original sketchy bash one-liner)"
# original was: wget -q -O - https://git.io/vQhTU | bash
# let's do a safer, explicit Go install from go.dev
GO_VERSION="1.23.2"  # bump here when you want
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
  amd64) GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz" ;;
  arm64) GO_TARBALL="go${GO_VERSION}.linux-arm64.tar.gz" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

cd /tmp
curl -fsSLO "https://go.dev/dl/${GO_TARBALL}"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "${GO_TARBALL}"
rm -f "${GO_TARBALL}"

# ensure go on PATH for *this* script run
export PATH="/usr/local/go/bin:${PATH}"

# persist in bashrc
if ! grep -qxF 'export PATH="/usr/local/go/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="/usr/local/go/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "[3/10] Docker (official repo)"
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# create docker group if needed
if ! getent group docker >/dev/null; then
  sudo groupadd docker
fi

# add current user
if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"
  # start a new shell with docker group so we can use docker right away
  newgrp docker <<'EOF'
docker version >/dev/null 2>&1 || true
EOF
fi

echo "[4/10] GitHub CLI (official apt repo)"
sudo mkdir -p -m 755 /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]; then
  tmpfile=$(mktemp)
  wget -nv -O "$tmpfile" https://cli.github.com/packages/githubcli-archive-keyring.gpg
  sudo mv "$tmpfile" /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt-get update
sudo apt-get install -y gh

echo "[5/10] Azure CLI"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "[6/10] kubectl (latest stable)"
KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

echo "[7/10] kubectl aliases"
if [ ! -f "$HOME/.kubectl_aliases" ]; then
  curl -fsSL https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases -o "$HOME/.kubectl_aliases"
fi

echo "[8/10] git global config (your org + http path)"
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
git config --global credential.useHttpPath true
git config --global url."https://dev.azure.com/msazure/".insteadof \
  "https://msazure.visualstudio.com/DefaultCollection/"

echo "[9/10] git-credential-azure (non-dotnet AzDO creds)"
go install github.com/hickford/git-credential-azure@latest
git config --global credential.helper "cache --timeout 21600"
git config --global --add credential.helper "azure -device"

echo "[10/10] azgoproxycreds (your tool) + env vars"
go install github.com/paulgmiller/azgoproxycreds@latest

BASHRC="$HOME/.bashrc"
append_if_missing () {
  local line="$1"
  local file="$2"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}
append_if_missing 'export GOPROXY="https://goproxyprod.goms.io"' "$BASHRC"
append_if_missing 'export GOPRIVATE="goms.io/aks/*,go.goms.io/aks/*,go.goms.io/caravel,go.goms.io/fleet*"' "$BASHRC"
append_if_missing 'export GONOPROXY=none' "$BASHRC"
append_if_missing 'export __AKS_DOCKER_BUILD_MOUNT_NETRC=1' "$BASHRC"

echo
echo "====================================================="
echo "Bootstrap complete."
echo
echo "What got installed:"
echo "- Go ${GO_VERSION} (/usr/local/go, PATH in ~/.bashrc)"
echo "- Docker + docker group (WSL/Ubuntu)"
echo "- GitHub CLI (gh)"
echo "- Azure CLI"
echo "- kubectl (${KUBECTL_VERSION})"
echo "- kubectl aliases (~/.kubectl_aliases)"
echo "- git configured for msazure -> dev.azure.com rewrite"
echo "- git-credential-azure + cache"
echo "- azgoproxycreds"
echo "- AKS/GOPROXY env vars in ~/.bashrc"
echo
echo "You may want to run now:"
echo "  source ~/.bashrc"
echo "  az login"
echo "  gh auth login"
echo "  azgoproxycreds   # when you need an updated token"
echo "====================================================="
