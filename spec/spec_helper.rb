require 'webmock'
require 'webmock/rspec'
require 'affirm'

include WebMock::API

TEST_URL = "https://public_key:secret_key@test.affirm.com"

RSpec.configure do |config|
  config.before(:suite) do
    Affirm::API.public_key = "public_key"
    Affirm::API.secret_key = "secret_key"
    Affirm::API.api_url    = "https://test.affirm.com"
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.syntax = [:should, :expect]
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random
end

def load_fixture(path)
  File.read(File.join(__dir__, "fixtures", path))
end
