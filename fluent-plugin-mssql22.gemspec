Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-mssql22"
  spec.version = "0.1.2"
  spec.authors = ["zle0"]
  spec.email   = ["zle0572"]

  spec.summary       = "fluent plugin to write to Microsoft SQL Server"
  spec.description   = "fluent plugin to write to Microsoft SQL Server"
  spec.homepage      = "http://github.com/zle0/fluent-plugin-mssql22"
  spec.license       = "MIT"

  spec.files         = ["lib/fluent/plugin/out_mssql22.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency 	'connection_pool', '~> 2.2'
  spec.add_dependency 	'tiny_tds', '~> 0.7'
end
