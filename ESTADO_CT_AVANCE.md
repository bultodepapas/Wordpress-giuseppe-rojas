# Estado de avance en CT (Proxmox) — WordPress

Fecha: 2026-02-18
Host CT: `100.82.85.18`
Hostname: `web-hosting-GR`
SO detectado: Debian 13 (trixie) en contenedor LXC

---

## 1) Conectividad y acceso

- Se validó acceso remoto por SSH al CT.
- Se configuró usuario operativo no-root: `wpops`.
- `wpops` quedó con permisos sudo para operación técnica.

### Hardening SSH aplicado

En `/etc/ssh/sshd_config`:
- `PasswordAuthentication no`
- `KbdInteractiveAuthentication no`
- `PubkeyAuthentication yes`
- `PermitRootLogin prohibit-password`

Además:
- Login por contraseña deshabilitado para operación.
- Root quedó solo por llave (sin password operativo).

---

## 2) Stack base instalado y activo

Instalado en CT:
- Nginx
- MariaDB
- PHP 8.4 + PHP-FPM
- utilidades: `curl`, `git`, `rsync`, `unzip`, `openssl`
- seguridad: `ufw`, `fail2ban`

Estado de servicios (verificado):
- `nginx`: active
- `mariadb`: active
- `php8.4-fpm`: active
- `fail2ban`: active

Firewall (UFW) activo con reglas:
- OpenSSH
- 80/tcp
- 443/tcp

---

## 3) WordPress instalado y operativo

Ruta de instalación:
- `/var/www/wordpress`

Acciones realizadas:
- Descarga e instalación de WordPress core.
- Creación de DB y usuario de DB dedicados.
- Configuración de `wp-config.php`.
- Instalación y uso de WP-CLI.
- Configuración de permalinks `/%postname%/`.
- Activación de código custom:
  - Theme: `mi-theme-child`
  - Plugin: `site-core`

Verificación HTTP:
- `http://127.0.0.1` -> `200 OK`
- `http://100.82.85.18` -> `200 OK`
- `http://100.82.85.18/wp-login.php` -> `200 OK`

---

## 4) Sincronización de código desde este repo

Se creó estructura remota de trabajo:
- `/opt/wp-stack/infra`
- `/opt/wp-stack/theme/mi-theme-child`
- `/opt/wp-stack/plugin/site-core`

Se sincronizó desde este repositorio al CT:
- `infra/`
- `wordpress/wp-content/themes/mi-theme-child/`
- `wordpress/wp-content/plugins/site-core/`

---

## 5) Pipeline de deploy preparado

Script operativo en:
- Repo local: `infra/scripts/deploy.sh`
- CT: `/opt/wp-stack/infra/scripts/deploy.sh`

Qué hace el deploy:
1. Backup rápido de `wp-content` (excluyendo uploads)
2. Pull de git si `APP_DIR` es repo
3. Sync de theme/plugin custom desde `/opt/wp-stack`
4. Permisos seguros (`www-data`)
5. Activación theme/plugin + flush cache vía WP-CLI

Estado:
- Ejecutado y validado con éxito en el CT.

---

## 6) Cloudflare Tunnel

- `cloudflared` instalado (v2026.2.0).
- Archivo base creado: `/etc/cloudflared/config.yml` (plantilla).
- Servicio **deshabilitado** hasta cargar credenciales reales de túnel y hostname final.

Faltante para publicar al mundo:
- `TUNNEL_ID`
- credencial JSON/token del túnel
- hostname final (ej. `blog.tudominio.com`)

---

## 7) Secretos y credenciales

Se generaron credenciales de WordPress/DB y se guardaron en:
- `/root/.wp-secrets/credentials.env`

Recomendación inmediata:
- Cambiar contraseña del admin WP tras primer login.
- Rotar credenciales finales antes de producción.

---

## 8) Estado actual resumido

**Completado:**
- Acceso SSH operativo y endurecido
- Stack web completo instalado
- WordPress funcionando en red local
- Theme/plugin custom activos
- Deploy script validado
- Base de Cloudflare lista

**Pendiente para producción pública:**
- Configurar y activar Cloudflare Tunnel con datos reales
- Ajustar dominio final
- SSL edge/WAF/rate limit en Cloudflare
- endurecimiento final de WordPress y política de backups definitiva
