module Affirm
  class Charge
    attr_reader :id, :amount, :created, :currency, :auth_hold, :payable, :order_id, :events, :details

    ##
    # RETRIEVE
    #
    # id - (required) string. The charge id, in format 'XXXX-XXXX'
    def self.retrieve(id, client: Affirm::API.client)
      new(attrs: {"id" => id}, client: client).refresh
    end

    ##
    # CREATE / AUTHORIZE
    #
    # checkout_token - (required) string. The charge token passed through the confirmation response.
    def self.create(checkout_token, client: Affirm::API.client)
      response = client.make_request!("/charges", :post, checkout_token: checkout_token)

      new(attrs: response.body, client: client)
    end

    ##
    # CAPTURE
    #
    # order_id - (optional) string. Your internal order id. This is stored for your own future reference.
    # shipping_carrier - (optional) string. The shipping carrier used to ship the items in the charge.
    # shipping_confirmation - (optional) string. The shipping confirmation for the shipment.
    def capture(order_id: nil, shipping_carrier: nil, shipping_confirmation: nil)
      api_request("/charges/#{id}/capture", :post, {
        order_id: order_id,
        shipping_carrier: shipping_carrier,
        shipping_confirmation: shipping_confirmation
      })
    end

    ##
    # VOID
    #
    def void
      api_request("/charges/#{id}/void", :post)
    end

    ##
    # REFUND
    #
    # amount - (optional) integer or null. The amount to refund in cents. The default amount is the remaining balance on the charge.
    def refund(amount: nil)
      api_request("/charges/#{id}/refund", :post, {
        amount: amount
      })
    end

    ##
    # UPDATE
    #
    # order_id - (optional) string. Your internal order id. This is stored for your own future reference.
    # shipping_carrier - (optional) string. The shipping carrier used to ship the items in the charge.
    # shipping_confirmation - (optional) string. The shipping confirmation for the shipment.
    def update(order_id: nil, shipping_carrier: nil, shipping_confirmation: nil)
      api_request("/charges/#{id}/update", :post, {
        order_id: order_id,
        shipping_carrier: shipping_carrier,
        shipping_confirmation: shipping_confirmation
      })
    end

    def initialize(attrs: {}, client: Affirm::API.client)
      @client = client
      set_attrs(attrs)
    end

    def refresh
      response = @client.make_request("/charges/#{id}", :get)

      set_attrs(response.body)

      self
    end

    def void?
      @void
    end

    private

    def set_attrs(attrs)
      @id        = attrs["id"]
      @amount    = attrs["amount"]
      @created   = attrs["created"]
      @currency  = attrs["currency"]
      @auth_hold = attrs["auth_hold"]
      @payable   = attrs["payable"]
      @void      = attrs["void"]
      @order_id  = attrs["order_id"]
      @details   = attrs["details"]
      @events    = parse_events(attrs["events"])
    end

    def parse_events(events_attrs)
      if events_attrs
        events_attrs.map { |event| ChargeEvent.new(event) }
      else
        []
      end
    end

    def api_request(url, method, params={})
      response = @client.make_request!(url, method, params)
      event = ChargeEvent.new(response.body)
      @events << event
      event
    end
  end
end
