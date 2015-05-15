require 'spec_helper'

describe Affirm::Charge do
  let(:id) { "ABCD" }
  let!(:request) do
    stub_request(request_method, request_url).to_return(status: response_code, body: response_body)
  end

  let(:response_code) { 200 }

  let(:charge) { Affirm::Charge.new(attrs: {"id" => id}) }

  describe "self.retrieve" do
    let(:request_method) { :get }
    let(:request_url) { "#{TEST_URL}/charges/#{id}" }
    let(:response_body) { load_fixture("charges/retrieve.json") }

    it "returns a charge" do
      charge = Affirm::Charge.retrieve(id)

      charge.should be_a Affirm::Charge
    end

    it "sets attributes" do
      charge = Affirm::Charge.retrieve(id)

      charge.id.should == id
      charge.created.should == "2014-03-18T19:19:04Z"
      charge.currency.should == "USD"
      charge.amount.should == 6100
      charge.auth_hold.should == 6100
      charge.payable.should == 0
      charge.void?.should == false
    end

    it "parses events" do
      charge = Affirm::Charge.retrieve(id)
      events = charge.events

      events.length.should == 1
      events.first.type.should == "auth"
    end

    context "not found" do
      let(:response_code) { 404 }

      it "raises an error" do
        expect { Affirm::Charge.retrieve(id) }.to raise_error(Affirm::ResourceNotFoundError)
      end
    end
  end

  describe "self.create" do
    let(:request_method) { :post }
    let(:request_url) { "#{TEST_URL}/charges" }
    let(:response_body) { load_fixture("charges/create.json") }

    it "returns a charge" do
      charge = Affirm::Charge.create("token")

      charge.should be_a Affirm::Charge
      charge.id.should == id
    end

    it "sends the correct body" do
      charge = Affirm::Charge.create("token")

      expect(WebMock).to have_requested(request_method, request_url).with(body: {
        checkout_token: "token"
      }.to_json)
    end

    context "failed response" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises a charge error" do
        expect { Affirm::Charge.create("token") }.to raise_error(Affirm::ChargeError)
      end
    end

    context "other api error" do
      let(:response_code) { 500 }
      let(:response_body) { "" }

      it "raises relevant error" do
        expect { Affirm::Charge.create("token") }.to raise_error(Affirm::ServerError)
      end
    end
  end

  describe "capture" do
    let(:request_method) { :post }
    let(:request_url) { "#{TEST_URL}/charges/#{id}/capture" }
    let(:response_body) { load_fixture("charges/capture.json") }

    it "POSTs to the capture url" do
      charge.capture

      expect(WebMock).to have_requested(request_method, request_url)
    end

    it "optionally allows tracking params" do
      params = { order_id: "order_id", shipping_carrier: "carrier", shipping_confirmation: "confirmation" }
      charge.capture(params)

      expect(WebMock).to have_requested(request_method, request_url).with(body: params.to_json)
    end

    it "adds the event to the charge" do
      expect { charge.capture }.to change { charge.events.length }.by(1)

      charge.events.last.type.should == "capture"
    end

    it "returns an event" do
      charge.capture.should be_a Affirm::ChargeEvent
    end

    context "failed response" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises a charge error" do
        expect { charge.capture }.to raise_error(Affirm::ChargeError)
      end
    end
  end

  describe "void" do
    let(:request_method) { :post }
    let(:request_url) { "#{TEST_URL}/charges/#{id}/void" }
    let(:response_body) { load_fixture("charges/void.json") }

    it "POSTs to the void url" do
      charge.void

      expect(WebMock).to have_requested(request_method, request_url)
    end

    it "adds the event to the charge" do
      expect { charge.void }.to change { charge.events.length }.by(1)

      charge.events.last.type.should == "void"
    end

    it "returns an event" do
      charge.void.should be_a Affirm::ChargeEvent
    end

    context "failed response" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises a charge error" do
        expect { charge.void }.to raise_error(Affirm::ChargeError)
      end
    end
  end

  describe "refund" do
    let(:request_method) { :post }
    let(:request_url) { "#{TEST_URL}/charges/#{id}/refund" }
    let(:response_body) { load_fixture("charges/refund.json") }

    it "POSTs to the refund url" do
      charge.refund

      expect(WebMock).to have_requested(request_method, request_url)
    end

    it "adds the event to the charge" do
      expect { charge.refund }.to change { charge.events.length }.by(1)

      charge.events.last.type.should == "refund"
    end

    it "returns an event" do
      charge.refund.should be_a Affirm::ChargeEvent
    end

    context "with amount" do
      it "sends the amount" do
        charge.refund(amount: 100)

        expect(WebMock).to have_requested(request_method, request_url).with(body: {
          amount: 100
        }.to_json)
      end
    end

    context "failed response" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises a charge error" do
        expect { charge.refund }.to raise_error(Affirm::ChargeError)
      end
    end
  end

  describe "update" do
    let(:request_method) { :post }
    let(:request_url) { "#{TEST_URL}/charges/#{id}/update" }
    let(:response_body) { load_fixture("charges/update.json") }

    it "POSTs to the update url" do
      charge.update

      expect(WebMock).to have_requested(request_method, request_url)
    end

    it "optionally allows params" do
      params = { order_id: "order_id", shipping_carrier: "carrier", shipping_confirmation: "confirmation" }
      charge.update(params)

      expect(WebMock).to have_requested(request_method, request_url).with(body: params.to_json)
    end

    it "adds the event to the charge" do
      expect { charge.update }.to change { charge.events.length }.by(1)

      charge.events.last.type.should == "update"
    end

    it "returns an event" do
      charge.update.should be_a Affirm::ChargeEvent
    end

    context "failed response" do
      let(:response_code) { 422 }
      let(:response_body) { load_fixture("charges/invalid_request.json") }

      it "raises an error" do
        expect { charge.update }.to raise_error(Affirm::ChargeError)
      end
    end
  end

  context "with specified client" do
    let(:client) { Affirm::Client.new(public_key: "other_public", secret_key: "other_secret") }

    let(:request_method) { :get }
    let(:response_body) { load_fixture("charges/retrieve.json") }
    let(:request_url) { /.*other_public:other_secret.*/ }

    it "uses the client's creds" do
      Affirm::Charge.retrieve(id, client: client)
    end
  end
end
