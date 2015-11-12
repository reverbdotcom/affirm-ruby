Gem::Specification.new do |s|
  s.name = "affirm"
  s.summary = "Affirm Ruby Client Library"
  s.description = "Ruby client library for integrating with Affirm financing payments"
  s.version = "1.1.2"
  s.license = "Apache License Version 2.0"
  s.author = "Reverb.com"
  s.email = "dev@reverb.com"
  s.has_rdoc = false
  s.files = Dir.glob ["README.md", "lib/**/*.{rb}", "spec/**/*", "*.gemspec"]

  s.add_dependency "typhoeus"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "3.2.0"
  s.add_development_dependency "webmock", "1.21.0"
end
