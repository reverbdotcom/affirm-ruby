require 'spec_helper'

describe Affirm::ChargeGateway do
  include_context 'public context'
  
  let(:id) { 'ABCD' }
  let(:charge_gateway) { described_class.new(gateway_attrs) }

  let!(:request) do
    stub_request(request_method, request_url).to_return(status: response_code, body: response_body)
  end

  let(:response_code) { 200 }

  describe "retrieve" do
    let(:request_method) { :get }
    let(:request_url) { get_request_url("/charges/#{id}") }
    let(:response_body) { load_fixture("charges/retrieve.json") }

    it "returns a charge" do
      charge = charge_gateway.retrieve(id)
      charge.should be_a Affirm::Charge
    end

    it "sets attributes" do
      charge = charge_gateway.retrieve(id)

      charge.id.should == id
      charge.created.should == "2014-03-18T19:19:04Z"
      charge.currency.should == "USD"
      charge.amount.should == 6100
      charge.auth_hold.should == 6100
      charge.payable.should == 0
      charge.void?.should == false
    end

    it "parses events" do
      charge = charge_gateway.retrieve(id)
      events = charge.events

      events.length.should == 1
      events.first.type.should == "auth"
    end

    context "not found" do
      let(:response_code) { 404 }

      it "raises an error" do
        expect { charge_gateway.retrieve(id) }.to raise_error(Affirm::ResourceNotFoundError)
      end
    end
  end

  describe "create" do
    let(:request_method) { :post }
    let(:request_url) { get_request_url("/charges") }
    let(:response_body) { load_fixture("charges/create.json") }

    it "returns a charge" do
      charge = charge_gateway.create("token")

      charge.should be_a Affirm::Charge
      charge.id.should == id
    end

    it "sends the correct body" do
      charge = charge_gateway.create("token")

      expect(WebMock).to have_requested(request_method, request_url).with(body: {
        checkout_token: "token"
      }.to_json)
    end

    it "sends the correct body with order_id" do
      charge = charge_gateway.create('token', 'order-id')

      expect(WebMock).to have_requested(request_method, request_url).with(body: {
        checkout_token: 'token', order_id: 'order-id'
      }.to_json)
    end

    context "failed response" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises a charge error" do
        expect { charge_gateway.create("token") }.to raise_error(Affirm::ChargeError)
      end
    end

    context "other api error" do
      let(:response_code) { 500 }
      let(:response_body) { "" }

      it "raises relevant error" do
        expect { charge_gateway.create("token") }.to raise_error(Affirm::ServerError)
      end
    end
  end

end
