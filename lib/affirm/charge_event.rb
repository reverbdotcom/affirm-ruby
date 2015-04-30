module Affirm
  class ChargeEvent
    attr_reader :id, :transaction_id, :type, :created,
      :amount, :fee, :order_id, :shipping_carrier, :shipping_confirmation,
      :fee_refunded

    def initialize(attrs)
      @id                    = attrs["id"]
      @transaction_id        = attrs["transaction_id"]
      @type                  = attrs["type"]
      @created               = attrs["created"]
      @amount                = attrs["amount"]
      @fee                   = attrs["fee"]
      @order_id              = attrs["order_id"]
      @shipping_carrier      = attrs["shipping_carrier"]
      @shipping_confirmation = attrs["shipping_confirmation"]
      @fee_refunded          = attrs["fee_refunded"]
    end
  end
end
