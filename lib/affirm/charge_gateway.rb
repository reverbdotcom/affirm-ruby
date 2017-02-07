module Affirm
  class ChargeGateway
    attr_reader :environment, :client

    LIVE_ENDPOINT = 'https://api.affirm.com/api/v2/'.freeze
    TEST_ENVPOINT = 'https://sandbox.affirm.com/api/v2/'.freeze

    LIVE_ENVS = %w(live production).freeze

    def initialize(environment:, public_key:, secret_key:)
      @environment = environment.to_s
      endpoint = LIVE_ENVS.include?(@environment) ? LIVE_ENDPOINT : TEST_ENVPOINT
      @client = Client.new(public_key: public_key, secret_key: secret_key, api_url: endpoint)
    end

    ##
    # RETRIEVE
    #
    # id - (required) string. The charge id, in format 'XXXX-XXXX'
    def retrieve(id)
      Charge.new(attrs: { 'id' => id }, client: client).refresh
    end

    ##
    # CREATE / AUTHORIZE
    #
    # checkout_token - (required) string. The charge token passed through the confirmation response.
    def create(checkout_token)
      response = client.make_request("/charges", :post, checkout_token: checkout_token)

      if response.success?
        Charge.new(attrs: response.body, client: client)
      else
        raise ChargeError.from_response(response)
      end
    end

  end
end
