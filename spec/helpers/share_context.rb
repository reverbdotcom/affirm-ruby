RSpec.shared_context 'public context' do
  let(:environment) { 'sandbox' }
  let(:public_key) { 'public_key' }
  let(:secret_key) { 'secret_key' }
  let(:api_url) { 'https://sandbox.affirm.com/api/v2/' }
  let(:gateway_attrs) { { public_key: public_key, secret_key: secret_key, environment: environment } }
  let(:client) { Affirm::Client.new(public_key: public_key, secret_key: secret_key, api_url: api_url) }
end
