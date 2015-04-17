module Affirm
  class Error < RuntimeError
    attr_reader :status_code, :code, :message

    def self.from_response(response)
      new(
        status_code: response.status_code,
        code:        response.code,
        message:     response.message
      )
    end

    def initialize(status_code:, code:, message:)
      @status_code = status_code
      @code = code
      @message = message
    end

    def to_s
      "#{status_code} #{code}: #{message}"
    end
  end
end
