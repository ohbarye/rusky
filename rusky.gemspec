# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rusky/version"

Gem.post_install do |installer|
  require "rusky"
  Rusky.install
end

Gem.pre_uninstall do |uninstaller|
  require "rusky"
  Rusky.uninstall
end

Gem::Specification.new do |spec|
  spec.name          = "rusky"
  spec.version       = Rusky::VERSION
  spec.authors       = ["ohbarye"]
  spec.email         = ["over.rye@gmail.com"]

  spec.summary       = "Add githooks easily"
  spec.description   = "Prevents bad commit or push (git hooks, pre-commit/precommit, pre-push/prepush, post-merge/postmerge and all that stuff...)"
  spec.homepage      = "https://github.com/ohbarye/rusky"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
