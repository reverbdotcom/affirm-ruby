require 'spec_helper'

describe Affirm::Client do
  let(:client) { described_class.new(public_key: public_key, secret_key: secret_key, api_url: api_url) }
  let(:public_key) { "public_key" }
  let(:secret_key) { "secret_key" }
  let(:api_url) { "https://testaffirm.com" }

  let(:request) { double("request", run: response) }
  let(:response) { double("response", success?: true, body: "", code: 200) }
  let(:affirm_url) { "https://public_key:secret_key@testaffirm.com/testpath" }

  describe "make_request" do
    before do
      Typhoeus::Request.stub(:new) { request }
    end

    it "makes the request to the api url" do
      client.make_request("testpath", :get)

      Typhoeus::Request.should have_received(:new) do |url, options|
        url.should == "https://testaffirm.com/testpath"
        options[:method].should == :get
      end

      request.should have_received(:run)
    end

    it "sends keys as basic auth" do
      client.make_request("testpath", :get)

      Typhoeus::Request.should have_received(:new) do |url, options|
        options[:userpwd].should == "public_key:secret_key"
      end
    end

    context "with params" do
      let(:params) { {"foo" => "bar"} }

      it "sends the params" do
        client.make_request("testpath", :post, params)

        Typhoeus::Request.should have_received(:new) do |url, options|
          options[:method].should == :post
          JSON.parse(options[:body]).should == params
        end
      end

      it "sets content type to application/json" do
        client.make_request("testpath", :post, params)

        Typhoeus::Request.should have_received(:new) do |url, options|
          options[:headers]["Content-Type"].should == "application/json"
        end
      end
    end

    context "authentication error" do

    end
  end

  describe "get" do
    before do
      Typhoeus::Request.stub(:new) { request }
    end

    it "sends a get request" do
      client.get("testpath")

      Typhoeus::Request.should have_received(:new) do |url, options|
        options[:method].should == :get
      end
    end
  end

  describe "post" do
    before do
      Typhoeus::Request.stub(:new) { request }
    end

    it "sends a post request" do
      client.post("testpath")

      Typhoeus::Request.should have_received(:new) do |url, options|
        options[:method].should == :post
      end
    end
  end

  describe "response" do
    before do
      stub_request(:get, affirm_url).
        to_return(status: 200, body: {foo: "bar"}.to_json)
    end

    it "parses the response" do
      response = client.get("testpath")

      response.should be_a(Affirm::Response)
      response.should be_success
      response.status_code.should == 200
      response.body["foo"].should == "bar"
    end
  end

  describe "errors" do
    context "authentication error" do
      before do
        stub_request(:get, affirm_url).
          to_return(status: 401, body: {status_code: 401, type: "unauthorized", code: "public-api-key-invalid"}.to_json)
      end

      it "raises Affirm::AuthenticationError" do
        expect { client.get("testpath") }.to raise_error(Affirm::AuthenticationError)
      end
    end

    context "server error" do
      before do
        stub_request(:get, affirm_url).
          to_return(status: 500, body: {status_code: 500}.to_json)
      end

      it "raises Affirm::ServerError" do
        expect { client.get("testpath") }.to raise_error(Affirm::ServerError)
      end
    end

    context "resource not found" do
      before do
        stub_request(:get, affirm_url).
          to_return(status: 404, body: {status_code: 404}.to_json)
      end

      it "raises Affirm::ResourceNotFoundError" do
        expect { client.get("testpath") }.to raise_error(Affirm::ResourceNotFoundError)
      end
    end
  end
end
