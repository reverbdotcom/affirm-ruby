module Affirm
  class ChargeError < Error
    DUPLICATE_CAPTURE_CODE = "duplicate-capture"
    
    def duplicate_capture?
      code.to_s == DUPLICATE_CAPTURE_CODE
    end

  end
end
