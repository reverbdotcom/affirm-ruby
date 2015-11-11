require 'typhoeus'

module Affirm
  class Client
    def initialize(public_key:, secret_key:, api_url: Affirm::API.api_url)
      @public_key = public_key
      @secret_key = secret_key
      @api_url = api_url
    end

    def post(path, data={})
      make_request(path, :post, data)
    end

    def get(path, data={})
      make_request(path, :get, data)
    end

    def make_request(path, method, data={})
      response = Typhoeus::Request.new(
        url(path),
        method: method,
        body: data.to_json,
        headers: affirm_headers(data),
        userpwd: user_password
      ).run

      affirm_response = parse_response(response)

      handle_errors(affirm_response)
    end

    private

    def parse_response(response)
      Affirm::Response.new(
        success: response.success?,
        status_code: response.code,
        body: response.body
      )
    end

    def handle_errors(affirm_response)
      if affirm_response.status_code == 401
        raise_error(Affirm::AuthenticationError, affirm_response)
      elsif affirm_response.status_code == 404
        raise_error(Affirm::ResourceNotFoundError, affirm_response)
      elsif affirm_response.status_code >= 500
        raise_error(Affirm::ServerError, affirm_response)
      end

      affirm_response
    end

    def raise_error(error_class, affirm_response)
      raise error_class.from_response(affirm_response)
    end

    def affirm_headers(data)
      { "Content-Type" => "application/json" } if data.length > 0
    end

    def user_password
      "#{@public_key}:#{@secret_key}"
    end

    def url(path)
      File.join(@api_url, path)
    end
  end
end
