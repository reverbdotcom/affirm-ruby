require 'spec_helper'

describe Affirm::Charges do
  before do
    stub_request(request_method, request_url).to_return(status: response_code, body: response_body)
  end

  let(:response_code) { 200 }

  describe "self.get" do
    let(:request_method) { :get }
    let(:request_url) { "#{TEST_URL}/charges/ABCD" }
    let(:response_body) { load_fixture("charges/get.json") }

    it "is successful" do
      response = Affirm::API.charges.get(charge_id: "ABCD")
      response.should be_success
      response.body["amount"].should == 6100
    end
  end

  describe "self.authorize" do
    let(:request_method) { :post }
    let(:request_url) { "#{TEST_URL}/charges/" }
    let(:response_body) { load_fixture("charges/authorize.json") }

    it "is successful" do
      response = Affirm::API.charges.authorize(checkout_token: "token")
      response.should be_success
    end

    context "bang method" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises an error on failure" do
        expect { Affirm::API.charges.authorize!(checkout_token: "token") }.to raise_error(Affirm::Error)
      end
    end
  end

  describe "self.capture" do
    let(:request_method) { :post }
    let(:request_url) { "#{TEST_URL}/charges/ABCD/capture" }
    let(:response_body) { load_fixture("charges/capture.json") }

    it "is successsful" do
      response = Affirm::API.charges.capture(charge_id: "ABCD")
      response.should be_success
    end

    context "bang method" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises an error on failure" do
        expect { Affirm::API.charges.capture!(charge_id: "ABCD") }.to raise_error(Affirm::Error)
      end
    end
  end

  describe "self.void" do
    let(:request_method) { :post }
    let(:request_url) { "#{TEST_URL}/charges/ABCD/void" }
    let(:response_body) { load_fixture("charges/void.json") }

    it "is successsful" do
      response = Affirm::API.charges.void(charge_id: "ABCD")
      response.should be_success
    end

    context "bang method" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises an error on failure" do
        expect { Affirm::API.charges.void!(charge_id: "ABCD") }.to raise_error(Affirm::Error)
      end
    end
  end

  describe "self.refund" do
    let(:request_method) { :post }
    let(:request_url) { "#{TEST_URL}/charges/ABCD/refund" }
    let(:response_body) { load_fixture("charges/refund.json") }

    it "is successsful" do
      response = Affirm::API.charges.refund(charge_id: "ABCD")
      response.should be_success
    end

    context "bang method" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises an error on failure" do
        expect { Affirm::API.charges.refund!(charge_id: "ABCD") }.to raise_error(Affirm::Error)
      end
    end
  end
end
