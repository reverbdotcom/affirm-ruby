require 'spec_helper'

describe Affirm::Charges do
  describe "self.authorize" do
    let(:checkout_token) { "ABCD" }

    it "is successsful" do
      VCR.use_cassette("affirm/authorize_charge", match_requests_on: [:uri, :method, :body]) do
        response = Affirm::API.charges.authorize(checkout_token: checkout_token)
        response.should be_success
      end
    end
  end
end
