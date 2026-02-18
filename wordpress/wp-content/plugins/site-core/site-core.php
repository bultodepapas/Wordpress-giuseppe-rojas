<?php
/**
 * Plugin Name: Site Core
 * Description: Funciones base del sitio (CPT/taxonomías) para mantener lógica fuera del theme.
 * Version: 0.1.0
 * Author: Proyecto Personal
 */

declare(strict_types=1);

if (!defined('ABSPATH')) {
    exit;
}

add_action('init', function (): void {
    register_post_type('proyecto', [
        'label' => 'Proyectos',
        'public' => true,
        'show_in_rest' => true,
        'menu_icon' => 'dashicons-portfolio',
        'supports' => ['title', 'editor', 'thumbnail', 'excerpt', 'revisions'],
        'has_archive' => true,
        'rewrite' => ['slug' => 'proyectos'],
    ]);

    register_post_type('auto', [
        'label' => 'Carro',
        'public' => true,
        'show_in_rest' => true,
        'menu_icon' => 'dashicons-car',
        'supports' => ['title', 'editor', 'thumbnail', 'excerpt', 'revisions'],
        'has_archive' => true,
        'rewrite' => ['slug' => 'carro'],
    ]);
});
