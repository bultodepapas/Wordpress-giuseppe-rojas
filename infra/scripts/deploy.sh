#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   sudo APP_DIR=/var/www/wordpress BRANCH=main bash deploy.sh

APP_DIR="${APP_DIR:-/var/www/wordpress}"
BRANCH="${BRANCH:-main}"
WEB_USER="${WEB_USER:-www-data}"
WEB_GROUP="${WEB_GROUP:-www-data}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/wp-deploy}"

log() {
  printf "[%s] %s\n" "$(date +%Y-%m-%dT%H:%M:%S%z)" "$1"
}

if [[ ! -d "$APP_DIR/.git" ]]; then
  log "ERROR: $APP_DIR no es un repositorio git"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

log "Creando backup rápido de wp-content (sin uploads)"
tar -czf "$BACKUP_DIR/wp-content-${TIMESTAMP}.tar.gz" \
  -C "$APP_DIR" \
  --exclude='wp-content/uploads' \
  wp-content

log "Actualizando código desde rama $BRANCH"
git -C "$APP_DIR" fetch origin
CURRENT_BRANCH="$(git -C "$APP_DIR" rev-parse --abbrev-ref HEAD)"
if [[ "$CURRENT_BRANCH" != "$BRANCH" ]]; then
  log "Cambiando a rama $BRANCH"
  git -C "$APP_DIR" checkout "$BRANCH"
fi
git -C "$APP_DIR" pull --ff-only origin "$BRANCH"

log "Aplicando permisos seguros"
chown -R "$WEB_USER:$WEB_GROUP" "$APP_DIR"
find "$APP_DIR" -type d -exec chmod 755 {} \;
find "$APP_DIR" -type f -exec chmod 644 {} \;

if command -v wp >/dev/null 2>&1; then
  log "Limpiando cache de WordPress (si aplica)"
  wp cache flush --path="$APP_DIR" --allow-root || true
fi

log "Deploy completado"
