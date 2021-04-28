module Affirm
  class Checkout
    attr_reader :id, :merchant, :shipping, :billing, :items, :discounts, :metadata, :order_id,
      :currency, :financing_program, :shipping_amount, :tax_amount, :total

    ##
    # RETRIEVE
    #
    # id - (required) string. The checkout id
    def self.retrieve(id, client: Affirm::API.client)
      new(attrs: {"id" => id}, client: client).refresh
    end

    def initialize(attrs: {}, client: Affirm::API.client)
      @client = client
      @id = attrs['id']
      set_attrs(attrs)
    end

    def refresh
      response = @client.make_request("/checkout/#{id}", :get)

      set_attrs(response.body)

      self
    end

    private

    def set_attrs(attrs)
      @merchant          = attrs["merchant"]
      @shipping          = attrs["shipping"]
      @billing           = attrs["billing"]
      @items             = attrs["items"]
      @discounts         = attrs["discounts"]
      @metadata          = attrs["metadata"]
      @order_id          = attrs["order_id"]
      @currency          = attrs["currency"]
      @financing_program = attrs["financing_program"]
      @shipping_amount   = attrs["shipping_amount"]
      @tax_amount        = attrs["tax_amount"]
      @total             = attrs["total"]
    end
  end
end
