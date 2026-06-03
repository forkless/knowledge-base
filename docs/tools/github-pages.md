← [Tools](../)

# GitHub Pages

GitHub Pages hosts static websites directly from a GitHub repository. This documentation site runs on it. No server, no database, no hosting bill.

## How It Works

1. Push markdown files to a GitHub repository
2. GitHub builds them with Jekyll (a static site generator)
3. The site is served at `https://yourname.github.io/repo-name/`

## Required Setup

In your repository **Settings → Pages**:

- **Source**: Deploy from a branch
- **Branch**: `master` (or `main`)
- **Folder**: `/docs`

## File Structure

```
docs/
├── _config.yml        ← Site title, description
├── _includes/
│   └── head-custom.html  ← Custom CSS/JS overrides
├── index.md           ← Landing page
├── ai/
│   └── comfyui.md
└── ...
```

Jekyll renders every `.md` file to `.html` automatically. Links between pages work with relative paths.

## _config.yml

Controls the site title and metadata:

```yaml
title: "Your Site Name"
description: "What your site is about"
```

This replaces the "repo-name" heading at the top of every page.

## Custom CSS

Add a file at `docs/_includes/head-custom.html` with `<style>` blocks to override the default theme:

```html
<style>
  body { background: #f7f7f7; }
  a { color: #e8a800; }
</style>
```

No rebuild needed — push and Pages applies it.

## Custom Domain

1. Add a `CNAME` file in `docs/` with your domain (e.g. `example.com`)
2. Configure your DNS provider with a CNAME record pointing to `yourname.github.io`
3. Enable "Custom domain" in Pages settings

## Build Timing

After pushing, Pages takes about 30–60 seconds to rebuild. If changes don't appear immediately, wait and hard refresh the browser tab.

## Limitations

- Static sites only — no PHP, no databases, no server-side code
- 1 GB repository limit, 100 GB monthly bandwidth
- Jekyll builds time out after 10 minutes
