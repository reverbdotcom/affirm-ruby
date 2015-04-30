module Affirm
  class Error < RuntimeError
    attr_reader :status_code, :code, :message

    def self.from_response(response)
      new(
        status_code: response.status_code,
        code:        response.code,
        message:     response.message || response.raw_body
      )
    end

    def initialize(status_code:, code:, message:)
      @status_code = status_code
      @code = code
      @message = message
    end

    def to_s
      if code || message
        "#{status_code} - (#{code}) #{message}"
      else
        status_code.to_s
      end
    end
  end
end
