module Affirm
  class API
    class << self
      attr_accessor :public_key, :secret_key, :api_url
      @@client = nil

      def client
        @@client ||= Affirm::Client.new(
          public_key: public_key,
          secret_key: secret_key,
          api_url: api_url
        )
      end
    end
  end
end
