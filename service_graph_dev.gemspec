require_relative "lib/service_graph_dev/version"

Gem::Specification.new do |spec|
  spec.name        = "service_graph_dev"
  spec.version     = ServiceGraphDev::VERSION
  spec.authors     = ["nildiert"]
  spec.summary     = "Dev-only Rails engine to visualize transitive service dependencies."
  spec.description = <<~DESC
    A mountable Rails engine that scans your app/services and packs/**/app/services
    directories via static analysis and renders an interactive graph showing
    the full blast radius of any service change. Useful for understanding
    transitive dependencies in large Rails codebases (including Packwerk layouts).
  DESC
  spec.homepage    = "https://github.com/nildiert/service_graph_dev"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.7"

  spec.files = Dir[
    "lib/**/*",
    "app/**/*",
    "config/**/*",
    "vendor/**/*",
    "LICENSE",
    "README.md",
  ]

  spec.add_dependency "railties", ">= 6.0"
  spec.add_dependency "actionpack", ">= 6.0"
end
