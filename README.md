# service_graph_dev

A dev-only Rails engine that visualizes transitive service dependencies in your Rails app.

Scan all `app/services` and `packs/**/app/services` files via static analysis and get an interactive graph showing exactly which services would be affected if you change a given one.

## Features

- Interactive vis.js network graph with force-directed layout
- BFS blast radius: shows every service affected at each depth level
- Dependency path tracing — see *why* a service is affected (via which intermediate services)
- Pack filter — scope analysis to a single Packwerk pack
- Depth slider (1-6) for controlling traversal distance
- Service search and descriptions from comment blocks
- 5-minute cache with one-click refresh
- GitHub dark color scheme, WCAG AA contrast
- **Auto-mount**: no need to edit `config/routes.rb` — the engine mounts itself in development

## Installation

Add to your `Gemfile` (in the `:development` group):

```ruby
group :development do
  gem "service_graph_dev", github: "nildiert/service_graph_dev"
end
```

If your project uses **dual-boot** (e.g. `Gemfile.next`), add it to the next Gemfile as well.

Then run:

```bash
bundle install
```

That's it. The engine **auto-mounts** at `/service_graph` in development. No generator or route editing needed.

Visit **http://localhost:3000/service_graph** and you're ready to go.

### Optional: install generator

If you want an initializer with all configuration options:

```bash
rails generate service_graph_dev:install
```

### Content Security Policy

vis-network.js is bundled within the gem and served from the engine's own route,
so no external CDN is needed. The engine uses CSP nonces automatically when
your app provides `content_security_policy_nonce` — no extra configuration required.

## Configuration

Create `config/initializers/service_graph_dev.rb` (or run the install generator):

```ruby
ServiceGraphDev.configure do |c|
  # Glob patterns for service files
  c.service_globs = [
    Rails.root.join("app/services/**/*.rb").to_s,
    Rails.root.join("packs/**/app/services/**/*.rb").to_s,
  ]

  # Cache TTL in seconds (default: 5 minutes)
  c.cache_ttl = 5 * 60

  # Environments where the engine is accessible (default: ["development"])
  c.allowed_environments = %w[development]

  # Auto-mount at /service_graph (default: true).
  # Set to false if you prefer to mount manually in config/routes.rb.
  c.auto_mount = true

  # Mount path (default: "/service_graph")
  c.mount_path = "/service_graph"
end
```

### Manual mount (if auto_mount is disabled)

```ruby
# config/routes.rb
if Rails.env.development?
  mount ServiceGraphDev::Engine, at: "/service_graph"
end
```

## How it works

The analyzer runs a two-pass static analysis:

1. **Pass 1** — collect all class names and metadata (file path, pack, parent class, description from preceding comment block). Handles module-nested classes (`module Foo\n  class Bar` -> `Foo::Bar`).
2. **Pass 2** — for each file, scan for references to known class names. The intersection of identifiers in the file with the set of known classes gives the dependency list.

A reverse index maps each class to the services that use it. BFS traversal on this reverse index computes the full transitive blast radius with predecessor tracking for path reconstruction.

## License

MIT
