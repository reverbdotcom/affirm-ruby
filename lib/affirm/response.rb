module Affirm
  class Response
    attr_reader :status_code, :raw_body

    def initialize(success:, status_code:, body:)
      @success = success
      @status_code = status_code.to_i
      @raw_body = body
    end

    def success?
      @success
    end

    def error?
      !success?
    end

    def body
      JSON.parse(@raw_body)
    rescue JSON::ParserError
      {}
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
