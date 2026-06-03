← [Skills](../)

# WordPress Plugin Standards

## File Header

```php
<?php
/**
 * Plugin Name:       My Plugin
 * Plugin URI:        https://github.com/user/my-plugin
 * Description:       Does one thing well.
 * Version:           1.0.0
 * Requires PHP:      8.1
 * Author:            Your Name
 * License:           MIT
 * Text Domain:       my-plugin
 */

declare(strict_types=1);
```

## Structure

```
my-plugin/
├── my-plugin.php          # Plugin header + bootstrap
├── includes/              # PHP classes
│   ├── class-admin.php
│   └── class-frontend.php
├── assets/                # Built assets (commit dist, not src)
│   ├── css/
│   ├── js/
│   └── img/
├── languages/             # .pot / .po / .mo files
└── readme.txt             # WordPress.org readme
```

- One class per file, PSR-4 autoloading if using Composer
- No WordPress hooks in the plugin header file beyond bootstrap

## Naming
- Prefix everything: functions `myplugin_do_thing()`, hooks `myplugin_saved_data`
- Constants: `MYPLUGIN_VERSION`
- Options: `myplugin_settings`
- Avoid generic names like `slug` or `settings` — prefix them

## Hooks
- Use `add_action()` / `add_filter()` in a dedicated bootstrapper method, not globally
- Prefer class methods over closures (testable, reusable)
- Document each hook with `@param` and `@return`:

```php
/**
 * Fires after a save sync completes.
 *
 * @param int    $save_id  The save file ID.
 * @param string $status   Result status: success | error
 */
do_action("myplugin_after_sync", $save_id, $status);
```

## Security
- `esc_attr()`, `esc_html()`, `esc_url()` for output
- `sanitize_text_field()`, `sanitize_email()`, etc. for input
- `wp_kses()` for HTML input with an allowlist
- `current_user_can()` before any admin operation
- `wp_nonce_field()` + `check_admin_referer()` for form submissions
- `$wpdb->prepare()` for all database queries

## Database
- Use `$wpdb->prefix` for table names, never hardcode
- Create tables on plugin activation with `dbDelta()`
- Drop tables on uninstall (dedicated `uninstall.php`)
- Store plugin version in `get_option()` for upgrade routines

## i18n
- Wrap all user-facing strings: `__("Save file", "my-plugin")`
- Generate .pot file before release: `wp i18n make-pot . languages/`
- Load text domain on `plugins_loaded`:

```php
add_action("plugins_loaded", function () {
    load_plugin_textdomain("my-plugin", false, dirname(plugin_basename(__FILE__)) . "/languages");
});
```

## Performance
- Register scripts/styles with `wp_register_*()`, enqueue only where needed
- Use `wp_enqueue_script()` with `array()` dependencies and `filemtime()` versioning
- Defer non-critical JS. Inline critical CSS in the `<head>`
- Use transients for expensive queries, `delete_transient()` on relevant saves

## Testing
- Use WP_Mock for unit tests (mocks WordPress functions without loading core)
- Use WordPress PHPUnit test suite for integration tests
- Test activation/deactivation/uninstall flows
- Test multisite if the plugin supports it

## Deployment
- .org: SVN deploy via GitHub Actions (10up/action-wordpress-plugin-deploy)
- Private: Composer + build step, commit `assets/` (built), ignore `node_modules/`
- Version in plugin header must match SVN tag for .org deployment
