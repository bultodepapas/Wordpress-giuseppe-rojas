#!/usr/bin/env bash
set -euo pipefail

# Bootstrap base para Ubuntu LTS
# Ejecutar como root en VM nueva

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y
apt-get install -y \
  nginx \
  mariadb-server \
  php-fpm php-mysql php-curl php-xml php-mbstring php-zip php-gd php-intl \
  unzip curl git ufw fail2ban

systemctl enable nginx
systemctl enable mariadb
systemctl enable php8.3-fpm || true

# Firewall básico
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "Bootstrap base completado"
