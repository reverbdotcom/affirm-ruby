require 'vcr'
require 'webmock'
require 'affirm'

include WebMock::API

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.configure do |config|
  config.before(:suite) do
    Affirm::API.public_key = "public_key"
    Affirm::API.secret_key = "secret_key"
    Affirm::API.api_url    = "https://sandbox.affirm.com/api/v2/"
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
