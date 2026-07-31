#!/usr/bin/env bash

set -euo pipefail

log_info() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

log_warn() {
    echo -e "\e[33m[WARN]\e[0m $1"
}

if command -v docker &> /dev/null; then
    log_warn "Docker is already installed: $(docker --version)"
else
    log_info "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu/docker.list \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
fi

if docker compose version &> /dev/null || command -v docker-compose &> /dev/null; then
    log_warn "Docker Compose is already installed."
else
    log_info "Installing Docker Compose..."
    sudo apt-get install -y docker-compose-plugin
fi

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    log_warn "Python3 is already installed (version $PYTHON_VERSION)."
    
    IS_SUFFICIENT=$(python3 -c 'import sys; print(sys.version_info >= (3, 9))')
    if [ "$IS_SUFFICIENT" != "True" ]; then
        log_info "Python version is lower than 3.9. Upgrading..."
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip python3-venv
    fi
else
    log_info "Installing Python3, pip, and venv..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv
fi

if python3 -m pip show django &> /dev/null; then
    log_warn "Django is already installed in the environment."
else
    log_info "Installing Django via pip..."
    python3 -m pip install --break-system-packages django
fi

log_info "All tools checked and installed successfully!"
echo "docker version:"
docker --version

echo "docker compose version:"
docker compose version

echo "python version:"
python3 --version

echo "django version:"
python3 -m django --version