module Affirm
  class Response
    attr_reader :status_code

    def initialize(success:, status_code:, body:)
      @success = success
      @status_code = status_code.to_i
      @body = body
    end

    def success?
      @success
    end

    def error?
      !success?
    end

    def body
      JSON.parse(@body)
    end

    def type
      body["type"]
    end

    def code
      body["code"]
    end

    def message
      body["message"]
    end

    def field
      body["field"]
    end
  end
end
