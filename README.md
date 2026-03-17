# service_graph_dev

A dev-only Rails engine that visualizes transitive service dependencies in your Rails app.

Scan all `app/services` and `packs/**/app/services` files via static analysis and get an interactive graph showing exactly which services would be affected if you change a given one.

## Features

- Interactive vis.js network graph with force-directed layout
- BFS blast radius: shows every service affected at each depth level
- Dependency path tracing — see *why* a service is affected (via which intermediate services)
- Pack filter — scope analysis to a single Packwerk pack
- Depth slider (1–6) for controlling traversal distance
- Service search and descriptions from comment blocks
- 5-minute cache with one-click refresh
- GitHub dark color scheme, WCAG AA contrast

## Installation

Add to your `Gemfile` (in the `:development` group):

```ruby
gem "service_graph_dev", github: "nildiert/service_graph_dev", group: :development
```

Then run:

```bash
bundle install
```

Mount the engine in `config/routes.rb`:

```ruby
if Rails.env.development?
  mount ServiceGraphDev::Engine, at: "/service_graph"
end
```

If your host app uses a Content Security Policy, allow `unpkg.com` in development so vis.js can load:

```ruby
# config/initializers/content_security_policy.rb
sources.push("https://unpkg.com") if Rails.env.development?
```

Then visit **http://localhost:3000/service_graph**.

## Configuration

You can override defaults in an initializer:

```ruby
# config/initializers/service_graph_dev.rb
ServiceGraphDev.configure do |c|
  # Additional glob patterns for service files
  c.service_globs = [
    Rails.root.join("app/services/**/*.rb").to_s,
    Rails.root.join("packs/**/app/services/**/*.rb").to_s,
  ]

  # Cache TTL in seconds (default: 5 minutes)
  c.cache_ttl = 5 * 60

  # Environments where the engine is accessible (default: ["development"])
  c.allowed_environments = %w[development]
end
```

## How it works

The analyzer runs a two-pass static analysis:

1. **Pass 1** — collect all class names and metadata (file path, pack, parent class, description from preceding comment block). Handles module-nested classes (`module Foo\n  class Bar` → `Foo::Bar`).
2. **Pass 2** — for each file, scan for references to known class names. The intersection of identifiers in the file with the set of known classes gives the dependency list.

A reverse index maps each class to the services that use it. BFS traversal on this reverse index computes the full transitive blast radius with predecessor tracking for path reconstruction.

## License

MIT
