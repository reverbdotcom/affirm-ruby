module Affirm
  class Charges
    def initialize(client)
      @client = client
      @namespace = "charges"
    end

    ######
    # GET
    #
    def get(charge_id:)
      make_request(charge_id, :get)
    end

    ######
    # AUTHORIZE
    #
    # checkout_token - (required) string. The charge token passed through the confirmation response.
    def authorize(checkout_token:)
      make_request("/", :post, checkout_token: checkout_token)
    end

    def authorize!(checkout_token:)
      response = authorize(checkout_token: checkout_token)
      assert_success(response)
    end

    ######
    # CAPTURE
    #
    # order_id - (optional) string. Your internal order id. This is stored for your own future reference.
    # shipping_carrier - (optional) string. The shipping carrier used to ship the items in the charge.
    # shipping_confirmation - (optional) string. The shipping confirmation for the shipment.
    def capture(charge_id:, order_id: nil, shipping_carrier: nil, shipping_confirmation: nil)
      make_request("#{charge_id}/capture", :post, {
        order_id: order_id,
        shipping_carrier: shipping_carrier,
        shipping_confirmation: shipping_confirmation
      })
    end

    def capture!(charge_id:, order_id: nil, shipping_carrier: nil, shipping_confirmation: nil)
      response = capture(charge_id: charge_id, order_id: order_id, shipping_carrier: shipping_carrier, shipping_confirmation: shipping_confirmation)
      assert_success(response)
    end

    ######
    # VOID
    #
    def void(charge_id:)
      make_request("#{charge_id}/void", :post)
    end

    def void!(charge_id:)
      response = void(charge_id: charge_id)
      assert_success(response)
    end

    ######
    # REFUND
    #
    # amount - (optional) integer or null. The amount to refund in cents. The default amount is the remaining balance on the charge.
    def refund(charge_id:, amount: nil)
      make_request("#{charge_id}/refund", :post, amount: amount)
    end

    def refund!(charge_id:, amount: nil)
      response = refund(charge_id: charge_id, amount: amount)
      assert_success(response)
    end

    private

    def make_request(path, method, data={})
      @client.make_request(File.join(@namespace, path), method, data)
    end

    def assert_success(response)
      raise Affirm::Error.from_response(response) if response.error?

      response
    end
  end
end
