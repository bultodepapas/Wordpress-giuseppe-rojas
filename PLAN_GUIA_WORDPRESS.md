# Plan y guía maestra: Blog personal en WordPress (VM Proxmox + Cloudflare Tunnel)

## 1) Objetivo del proyecto
Construir un sitio personal en **WordPress** (base principal), enfocado en:
- Blog de proyectos
- Canal de YouTube
- Contenido de tu carro
- Imagen visual **hermosa, elegante y trabajada**
- Administración sencilla desde **wp-admin** (sin depender de desarrollo para cada cambio)

---

## 2) Decisiones técnicas principales

### CMS y edición
- **WordPress autohospedado** como núcleo.
- Edición por bloques (Gutenberg) + patrón de diseño consistente.
- Todo el contenido editable desde wp-admin: páginas, entradas, menú, imágenes, textos, bloques, formularios.

### Infraestructura
- **Proxmox VM** dedicada para WordPress.
- **Cloudflare Tunnel** para exponer el sitio al público sin abrir puertos en tu red.
- DNS y SSL gestionados por Cloudflare.

### Filosofía visual
- Diseño premium minimalista: tipografía cuidada, ritmo visual, espacios amplios, microinteracciones discretas y consistencia de estilos.
- Prioridad a rendimiento + estética (no sacrificar velocidad por “efectos”).

---

## 3) Arquitectura recomendada

```text
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
- Certificados: manejados por Cloudflare en el borde (edge)

---

## 4) Especificación sugerida de la VM (Proxmox)

### Perfil inicial (suficiente para blog personal serio)
- vCPU: 2
- RAM: 4 GB
- Disco: 40–80 GB (SSD)
- Red: bridge estándar de Proxmox

### Escalado futuro
- Subir a 4 vCPU / 8 GB RAM si hay más tráfico, plugins pesados o video embeds masivos.

### Buenas prácticas VM
- Snapshot antes de cambios grandes
- Backups automáticos de VM en Proxmox
- Usuario no-root + acceso SSH por llave

---

## 5) Plan de implementación por fases

## Fase A — Base del servidor
1. Crear VM Ubuntu LTS en Proxmox.
2. Hardening inicial:
   - actualizar paquetes
   - fail2ban
   - firewall (ufw/nftables)
   - desactivar login root por SSH
3. Instalar Nginx, PHP-FPM, MariaDB.
4. Crear DB y usuario dedicado para WordPress.

## Fase B — WordPress limpio
1. Descargar e instalar WordPress.
2. Configurar `wp-config.php` con:
   - credenciales DB
   - salts/keys
   - prefijo de tablas personalizado
   - `DISALLOW_FILE_EDIT` para seguridad
3. Configurar permalink “Post name”.
4. Configuración inicial de idioma, zona horaria, título y lectura.

## Fase C — Publicación con Cloudflare Tunnel
1. Crear túnel con `cloudflared` en la VM.
2. Asociar hostname (ej. `blog.tudominio.com`) al túnel.
3. Configurar ingress hacia Nginx local (`http://localhost:80`).
4. Verificar acceso público y SSL activo desde Cloudflare.
5. Activar reglas de seguridad de Cloudflare (WAF y rate limiting básico).

## Fase D — Diseño visual premium
1. Elegir base visual:
   - Opción recomendada: theme liviano orientado a bloques (Block Theme).
2. Definir sistema de diseño:
   - Paleta (3–5 colores)
   - Tipografías (máx 2 familias)
   - Escala tipográfica
   - Espaciado y radios
3. Construir plantillas clave:
   - Home (hero + secciones principales)
   - Blog
   - Proyectos
   - YouTube
   - Carro
   - About / Contacto
4. Ajustar responsive (mobile-first).

## Fase E — Contenido y estructura editorial
1. Definir tipos de contenido:
   - Entradas estándar (blog)
   - Custom Post Type `proyecto`
   - Custom Post Type `auto`
2. Taxonomías recomendadas:
   - `tema`, `tecnologia`, `estado_proyecto`, etc.
3. Crear bloques reutilizables/patrones:
   - Tarjeta de proyecto
   - Lista de videos recientes
   - Timeline de mejoras del carro

## Fase F — Rendimiento, SEO, seguridad, backups
1. Caché de página + object cache (Redis).
2. Optimización de imágenes (WebP/AVIF, lazy load).
3. SEO técnico básico (metadatos, sitemap, schema).
4. Seguridad WP:
   - limitar intentos login
   - 2FA para admin
   - ocultar versión WP cuando aplique
5. Backups automáticos:
   - DB diaria
   - archivos semanales
   - copias externas (NAS o almacenamiento remoto)

---

## 6) Estructura de páginas recomendada

- **Home**: propuesta de valor + secciones destacadas (Proyectos, YouTube, Carro, Blog)
- **Proyectos**: grid visual + filtros
- **YouTube**: feed curado + CTA a suscripción
- **Mi carro**: bitácora, mods, fotos, costos, estado
- **Blog**: artículos por categoría
- **Sobre mí**
- **Contacto**

---

## 7) Plugins recomendados (enfoque limpio)

Mantener pocos plugins para evitar deuda técnica.

- SEO: Rank Math o Yoast (uno solo)
- Caché: LiteSpeed Cache (si aplica) o WP Rocket / alternativa compatible con Nginx
- Seguridad: Wordfence o Solid Security (uno solo)
- Formularios: Fluent Forms o WPForms
- Imágenes: ShortPixel / Imagify
- Backup: UpdraftPlus o solución a nivel servidor
- Redirecciones: Redirection
- SMTP: WP Mail SMTP

> Regla: instalar solo lo necesario, validar compatibilidad y mantener actualizado.

---

## 8) Lineamientos de diseño (para que se vea “hermoso y elegante”)

1. **Jerarquía tipográfica clara**: títulos con peso y cuerpo de texto legible.
2. **Mucho espacio en blanco**: mejora percepción premium.
3. **Paleta sobria**: color principal + acento controlado.
4. **Consistencia**: botones, tarjetas, bordes y sombras uniformes.
5. **Imágenes de calidad**: portada coherente por sección.
6. **Animaciones mínimas**: suaves y con propósito.
7. **Mobile primero**: la experiencia móvil debe ser impecable.

---

## 9) Qué podrás editar tú desde wp-admin

Sin tocar código, podrás editar:
- Páginas y entradas
- Menús y navegación
- Encabezado/pie (si el theme es de bloques)
- Imágenes, galerías, embeds de YouTube
- Categorías y etiquetas
- Patrones y bloques reutilizables
- Formularios y textos generales

Con intervención técnica ocasional:
- Cambios estructurales grandes del theme
- Nuevos CPT/taxonomías complejas
- Integraciones avanzadas

---

## 10) Operación y mantenimiento

### Rutina semanal
- Actualizar core, themes y plugins
- Revisar backups
- Revisar alertas de seguridad

### Rutina mensual
- Test de restauración de backup
- Auditoría de rendimiento (Core Web Vitals)
- Limpieza de plugins no usados

### Regla de oro
- Todo cambio grande: snapshot de VM + backup DB antes de aplicar.

---

## 11) Roadmap de ejecución sugerido

1. Infraestructura VM + stack web
2. WordPress base + seguridad inicial
3. Cloudflare Tunnel + dominio
4. Theme + sistema de diseño
5. Estructura de contenido (CPT/taxonomías)
6. Carga inicial de contenido
7. Optimización final y lanzamiento

---

## 12) Checklist de salida a producción

- [ ] Acceso por dominio final funcionando
- [ ] SSL activo en Cloudflare
- [ ] WAF y reglas básicas activas
- [ ] Login admin protegido con 2FA
- [ ] Backups automáticos verificados
- [ ] Home responsive validada en móvil
- [ ] SEO básico configurado
- [ ] Rendimiento aceptable (sin plugins innecesarios)

---

## 13) Próximo paso sugerido
Definir contigo estas 5 decisiones para pasar del plan a implementación:
1. Dominio/subdominio final
2. Theme base (Astra, Kadence, GeneratePress, Block Theme puro)
3. Estilo visual (sobrio oscuro, claro minimal, editorial, etc.)
4. Plugins definitivos (mínimos)
5. Política de backups (destino y frecuencia exacta)

---

Si quieres, en el siguiente paso te preparo una versión **"plan de ejecución técnico"** con comandos concretos para Ubuntu, Nginx, MariaDB y cloudflared, lista para aplicarla directamente en tu VM de Proxmox.
