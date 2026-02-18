<?php

declare(strict_types=1);

add_action('wp_enqueue_scripts', function (): void {
    $parent = 'parent-style';
    wp_enqueue_style($parent, get_template_directory_uri() . '/style.css');

    wp_enqueue_style(
        'mi-theme-child-style',
        get_stylesheet_uri(),
        [$parent],
        wp_get_theme()->get('Version')
    );
});
