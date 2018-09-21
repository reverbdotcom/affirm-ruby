module Affirm
  class ChargeError < Error
    DUPLICATE_CAPTURE_CODE = "duplicate-capture".freeze
    VOIDED_CAPTURE_CODE = "capture-voided".freeze

    def duplicate_capture?
      code.to_s == DUPLICATE_CAPTURE_CODE
    end

    def voided_capture?
      code.to_s == VOIDED_CAPTURE_CODE
    end
  end
end
