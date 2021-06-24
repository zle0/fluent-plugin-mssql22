lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-mssql22"
  spec.version = "0.1.0"
  spec.authors = ["zle0"]
  spec.email   = ["zle0572"]

  spec.summary       = "fluent plugin to write to Microsoft SQL Server"
  spec.description   = "fluent plugin to write to Microsoft SQL Server"
  spec.homepage      = "http://github.com/zle0/fluent-plugin-mssql22"
  spec.license       = "MIT"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
  spec.add_dependency 	'connection_pool', '~> 2.2'
  spec.add_dependency 	'tiny_tds', '~> 0.7'
end
