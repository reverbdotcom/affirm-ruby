require 'spec_helper'

describe Affirm::Charge do
  include_context 'public context'

  let(:id) { "ABCD" }
  let(:charge) { Affirm::Charge.new(attrs: {"id" => id}, client: client) }

  let!(:request) do
    stub_request(request_method, request_url).to_return(status: response_code, body: response_body)
  end

  let(:response_code) { 200 }

  describe "capture" do
    let(:request_method) { :post }
    let(:request_url) { get_request_url("/charges/#{id}/capture") }
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

      context "when the failed response is a duplicate capture" do
        let(:response_code) { 400 }
        let(:response_body) { load_fixture("charges/duplicate_capture.json") }
        it "the raised error is a duplicate capture" do
          begin
            charge.capture
          rescue Affirm::ChargeError => e
            e.should be_duplicate_capture
          end
        end
      end
    end
  end

  describe "void" do
    let(:request_method) { :post }
    let(:request_url) { get_request_url("/charges/#{id}/void") }
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
    let(:request_url) { get_request_url("/charges/#{id}/refund") }
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
    let(:request_url) { get_request_url("/charges/#{id}/update") }
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
end
