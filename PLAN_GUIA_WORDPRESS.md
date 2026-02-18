# Plan y guía maestra: Blog personal en WordPress (VM Proxmox + Cloudflare Tunnel)

ip del ct 100.82.85.18

## 1) Objetivo del proyecto
Construir un sitio personal en **WordPress** (base principal), enfocado en:
- Blog de proyectos
- Canal de YouTube
- Contenido de tu carro
- Imagen visual **hermosa, elegante y trabajada**
- Administración sencilla desde **wp-admin** (sin depender de desarrollo para cada cambio)

Además, operar el proyecto con un flujo claro entre:
- Tu VS Code/local
- Repositorio GitHub
- VM en Proxmox

---

## 2) Cómo te puedo ayudar con la VM (control remoto)

Sí, puedo ejecutar comandos remotos por SSH **si desde este entorno hay conectividad a la VM** y si me compartes acceso válido.

## Recomendación de seguridad para acceso
**No usar usuario root ni contraseña compartida por chat como método principal.**
Mejor usar:
1. Usuario técnico dedicado (ej: `wpops`)
2. Acceso por **llave SSH**
3. Permisos `sudo` limitados
4. Opcional: rotar o eliminar la llave cuando terminemos

## Método recomendado de acceso
- Tú creas usuario en VM: `wpops`
- Añades mi clave pública temporal a `~/.ssh/authorized_keys`
- Yo opero por SSH
- Al finalizar, eliminas esa clave

Esto te deja trazabilidad y control total.

---

## 3) Decisiones técnicas principales

### CMS y edición
- **WordPress autohospedado** como núcleo.
- Edición por bloques (Gutenberg) + patrones reutilizables.
- Todo el contenido cotidiano editable desde wp-admin: páginas, entradas, menú, imágenes, textos, bloques, formularios.

### Infraestructura
- **Proxmox VM** dedicada para WordPress.
- **Cloudflare Tunnel** para exponer el sitio al público sin abrir puertos entrantes.
- DNS, SSL edge, WAF y CDN en Cloudflare.

### Filosofía visual
- Diseño premium minimalista: tipografía cuidada, ritmo visual, espacios amplios, consistencia en componentes.
- Prioridad a rendimiento + estética (sin efectos pesados innecesarios).

---

## 4) Arquitectura recomendada

```text
[Tu VS Code local] -> GitHub (repo privado)
                         |
                         | git pull / deploy script
                         v
Usuario -> Cloudflare (DNS/SSL/WAF/CDN) -> Cloudflare Tunnel (cloudflared)
       -> VM Proxmox (Ubuntu + Nginx + PHP-FPM + MariaDB + WordPress)
```

### Stack en VM
- Ubuntu Server LTS
- Nginx
- PHP 8.3 + PHP-FPM
- MariaDB 11 (o MySQL 8)
- WordPress latest stable
- Redis (opcional recomendado para object cache)

---

## 5) Propuesta clave: separar “contenido” vs “código”

Para que tú edites fácil y el sistema sea mantenible:

## A. Lo que se edita en wp-admin (día a día)
- Entradas, páginas, imágenes
- Menús
- Plantillas y patrones (si usamos block theme)
- Formularios y textos

## B. Lo que se versiona en GitHub (equipo técnico)
- Theme hijo/custom
- Plugins propios (si hay)
- Configuración de infraestructura/scripts
- Backups de configuración (no de media pesada)

**Regla práctica:**
- Contenido editorial -> wp-admin
- Lógica/estilo estructural -> GitHub + deploy a VM

---

## 6) Flujo recomendado local -> GitHub -> VM

## Flujo operativo (recomendado)
1. Editas código en VS Code local (theme/plugin/config)
2. Commit/push a GitHub (`main` o `staging`)
3. VM hace deploy por pull controlado (manual o automatizado)
4. Se limpian cachés
5. Verificación funcional

## Opciones de despliegue

### Opción 1 (simple, recomendada al inicio): Deploy manual por SSH
- Conectas por SSH
- Ejecutas script `/opt/wp-deploy/deploy.sh`
- El script hace backup rápido + `git pull` + permisos + cache flush

Ventaja: máxima visibilidad y bajo riesgo para empezar.

### Opción 2 (semiautomática): GitHub webhook + script en VM
- Push a rama de producción dispara deploy
- Requiere hardening extra

Ventaja: menos pasos manuales.

### Opción 3 (avanzada): GitHub Actions + SSH deploy
- Pipeline valida y luego despliega por SSH
- Recomendado cuando ya esté estable

Ventaja: control CI/CD y calidad previa al deploy.

---

## 7) Estructura de repositorio sugerida

```text
repo/
  infra/
    nginx/
    php/
    cloudflared/
    scripts/
  wordpress/
    wp-content/
      themes/mi-theme-child/
      plugins/mi-plugin-custom/   (si aplica)
  docs/
    runbook-operacion.md
```

Importante:
- **No** subir `wp-config.php` con secretos reales
- **No** subir dumps con datos sensibles
- Usar `.env` o plantillas seguras para credenciales

---

## 8) Especificación sugerida de la VM (Proxmox)

### Perfil inicial
- vCPU: 2
- RAM: 4 GB
- Disco: 40–80 GB SSD

### Escalado
- 4 vCPU / 8 GB RAM si crece tráfico o complejidad.

### Buenas prácticas
- Snapshot antes de cambios grandes
- Backups programados en Proxmox
- SSH solo por llave
- Usuario no-root

---

## 9) Plan de implementación por fases (mejorado)

## Fase A — Base VM + acceso remoto seguro
1. Crear VM Ubuntu LTS
2. Hardening inicial (updates, fail2ban, firewall, SSH hardening)
3. Crear usuario técnico (`wpops`) con llave SSH
4. Validar acceso remoto desde este entorno

## Fase B — Stack web + WordPress
1. Instalar Nginx, PHP-FPM, MariaDB
2. Crear DB/user WordPress
3. Instalar WordPress
4. Configurar `wp-config.php` seguro (salts, prefijo tablas, `DISALLOW_FILE_EDIT`)

## Fase C — Cloudflare Tunnel
1. Instalar/configurar `cloudflared`
2. Crear túnel y hostname (`blog.tudominio.com`)
3. Ingress a `http://localhost:80`
4. Validar SSL edge + reglas WAF/rate-limit

## Fase D — Diseño visual premium
1. Elegir base (block theme liviano)
2. Definir design system (color, tipo, spacing)
3. Construir Home/Blog/Proyectos/YouTube/Carro/About
4. Ajuste mobile-first

## Fase E — GitHub + despliegue controlado
1. Estructurar repo (theme/plugin/infra/scripts)
2. Configurar `.gitignore` correcto para WordPress
3. Crear script de deploy en VM
4. Definir estrategia: manual primero, automatización después

## Fase F — Operación estable
1. Backups (DB diaria, archivos semanales, copia externa)
2. Monitoreo básico (disco, RAM, servicios)
3. Plan de rollback (snapshot + restore DB)

---

## 10) Estrategia de backups y rollback

## Backups mínimos
- DB: diario
- `wp-content/uploads`: semanal
- Snapshot VM: antes de cambios grandes

## Rollback
1. Si falla deploy de código: revert de commit + redeploy
2. Si falla por datos/config: restaurar DB + archivos
3. Si falla sistema: revert snapshot VM

---

## 11) Operación diaria (quién toca qué)

## Tú (wp-admin)
- Publicar y editar contenido
- Gestionar menús, páginas, medios
- Ajustes editoriales

## Yo (agente técnico)
- Cambios de código y estructura
- Hardening y mantenimiento técnico
- Deploy y troubleshooting

---

## 12) Checklist previo a ejecutar conexión SSH real

- [ ] VM con IP fija accesible en tu red
- [ ] Usuario técnico creado (no root)
- [ ] Llave SSH autorizada
- [ ] `sudo` habilitado para ese usuario
- [ ] Firewall permitiendo SSH solo desde LAN (o IP concreta)
- [ ] Confirmar si usaremos deploy manual o automático

---

## 13) Checklist salida a producción

- [ ] Dominio/subdominio funcionando por Cloudflare Tunnel
- [ ] SSL activo
- [ ] WAF/rate-limit básico activo
- [ ] Admin WP protegido con 2FA
- [ ] Backups verificados con prueba de restauración
- [ ] Sitio responsive y rápido
- [ ] Flujo GitHub -> VM probado

---

## 14) Decisiones que necesitamos cerrar ahora

1. Dominio final (ej. `blog.tudominio.com`)
2. Theme base (block theme recomendado)
3. Flujo de deploy inicial: manual por SSH o semiautomático
4. Política de backups exacta (destino y retención)
5. Método de acceso SSH (llave temporal recomendada)

---

## 15) Siguiente paso práctico
Cuando quieras, pasamos a ejecución real en este orden:
1. Me compartes IP de VM + usuario técnico + método de llave SSH
2. Validamos conexión SSH
3. Configuro base del servidor
4. Dejo WordPress + cloudflared + deploy script listos
5. Te entrego runbook operativo para que tú lo puedas mantener
