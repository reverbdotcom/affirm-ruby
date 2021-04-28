require 'spec_helper'

describe Affirm::Checkout do
  let(:id) { "ABCD" }
  let!(:request) do
    stub_request(request_method, request_url).to_return(status: response_code, body: response_body)
  end

  let(:response_code) { 200 }

  let(:checkout) { Affirm::Checkout.new(attrs: {"id" => id}) }

  describe "self.retrieve" do
    let(:request_method) { :get }
    let(:request_url) { "#{TEST_URL}/checkout/#{id}" }
    let(:response_body) { load_fixture("checkout/retrieve.json") }

    it "returns a checkout" do
      checkout = Affirm::Checkout.retrieve(id)

      checkout.should be_a Affirm::Checkout
    end

    it "sets attributes" do
      checkout = Affirm::Checkout.retrieve(id)

      checkout.currency.should == "USD"
      checkout.total.should == 6100
      checkout.order_id.should == "order_id_123"
      checkout.financing_program.should == "flyus_3z6r12r"
      checkout.tax_amount.should == 700
      checkout.shipping_amount.should == 800
      checkout.metadata.should == { "mode" => "modal", "invoice_id" => "invoice_id_123"}
    end

    it "does not unset the id" do
      checkout = Affirm::Checkout.retrieve(id)

      checkout.id.should == id
    end

    context "not found" do
      let(:response_code) { 404 }

      it "raises an error" do
        expect { Affirm::Checkout.retrieve(id) }.to raise_error(Affirm::ResourceNotFoundError)
      end
    end
  end

  context "with specified client" do
    let(:client) { Affirm::Client.new(public_key: "other_public", secret_key: "other_secret") }

    let(:request_method) { :get }
    let(:response_body) { load_fixture("checkout/retrieve.json") }
    let(:request_url) { /.*other_public:other_secret.*/ }

    it "uses the client's creds" do
      Affirm::Checkout.retrieve(id, client: client)
    end
  end
end
