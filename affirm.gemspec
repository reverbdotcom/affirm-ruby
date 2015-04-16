Gem::Specification.new do |s|
  s.name = "affirm"
  s.summary = "Affirm Ruby Client Library"
  s.description = "Ruby client library for integrating with Affirm financing payments"
  s.version = "0.0.1"
  s.license = "MIT"
  s.author = "Reverb.com"
  s.email = "dev@reverb.com"
  s.has_rdoc = false
  s.files = Dir.glob ["README.md", "lib/**/*.{rb}", "spec/**/*", "*.gemspec"]

  s.add_dependency "typhoeus"

  s.add_development_dependency "rspec", "3.2.0"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr", "2.9.3"
end
