#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   sudo APP_DIR=/var/www/wordpress STACK_DIR=/opt/wp-stack BRANCH=main bash deploy.sh

APP_DIR="${APP_DIR:-/var/www/wordpress}"
STACK_DIR="${STACK_DIR:-/opt/wp-stack}"
BRANCH="${BRANCH:-main}"
WEB_USER="${WEB_USER:-www-data}"
WEB_GROUP="${WEB_GROUP:-www-data}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/wp-deploy}"

log() {
  printf "[%s] %s\n" "$(date +%Y-%m-%dT%H:%M:%S%z)" "$1"
}

if [[ ! -d "$APP_DIR" ]]; then
  log "ERROR: APP_DIR no existe: $APP_DIR"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

if [[ -d "$APP_DIR/wp-content" ]]; then
  log "Creando backup rápido de wp-content (sin uploads)"
  tar -czf "$BACKUP_DIR/wp-content-${TIMESTAMP}.tar.gz" \
    -C "$APP_DIR" \
    --exclude='wp-content/uploads' \
    wp-content
fi

if [[ -d "$APP_DIR/.git" ]]; then
  log "Actualizando código desde rama $BRANCH"
  git -C "$APP_DIR" fetch origin
  CURRENT_BRANCH="$(git -C "$APP_DIR" rev-parse --abbrev-ref HEAD)"
  if [[ "$CURRENT_BRANCH" != "$BRANCH" ]]; then
    log "Cambiando a rama $BRANCH"
    git -C "$APP_DIR" checkout "$BRANCH"
  fi
  git -C "$APP_DIR" pull --ff-only origin "$BRANCH"
else
  log "APP_DIR no es repo git, se omite git pull"
fi

if [[ -d "$STACK_DIR/theme/mi-theme-child" ]]; then
  log "Sincronizando theme custom"
  mkdir -p "$APP_DIR/wp-content/themes/mi-theme-child"
  rsync -a --delete "$STACK_DIR/theme/mi-theme-child/" "$APP_DIR/wp-content/themes/mi-theme-child/"
fi

if [[ -d "$STACK_DIR/plugin/site-core" ]]; then
  log "Sincronizando plugin custom"
  mkdir -p "$APP_DIR/wp-content/plugins/site-core"
  rsync -a --delete "$STACK_DIR/plugin/site-core/" "$APP_DIR/wp-content/plugins/site-core/"
fi

log "Aplicando permisos seguros"
chown -R "$WEB_USER:$WEB_GROUP" "$APP_DIR"
find "$APP_DIR" -type d -exec chmod 755 {} \;
find "$APP_DIR" -type f -exec chmod 644 {} \;
chmod 640 "$APP_DIR/wp-config.php" || true

if command -v wp >/dev/null 2>&1; then
  log "Activando theme/plugin y limpiando cache"
  wp plugin activate site-core --path="$APP_DIR" --allow-root || true
  wp theme activate mi-theme-child --path="$APP_DIR" --allow-root || true
  wp cache flush --path="$APP_DIR" --allow-root || true
fi

log "Deploy completado"
