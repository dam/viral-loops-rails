
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "viral-loops-rails/version"

Gem::Specification.new do |spec|
  spec.name          = "viral-loops-rails"
  spec.version       = VLoopsRails::VERSION
  spec.authors       = ["Damien Imberdis"]
  spec.email         = ["imberdis.damien@gmail.com"]

  spec.summary       = %q{Unofficial. Integrate viral-loops in a Rails app. https://viral-loops.com/}
  spec.description   = %q{}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'httparty', '0.16.2'
  spec.add_dependency 'activesupport'
end
