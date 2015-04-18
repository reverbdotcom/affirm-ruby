# affirm-ruby
Ruby client library for integrating with Affirm financing (https://www.affirm.com/)

Requires Ruby 2.1 or greater.

[![Build Status](https://travis-ci.org/reverbdotcom/affirm-ruby.png?branch=master)](https://travis-ci.org/reverbdotcom/affirm-ruby)

## Install
Add to your gemfile:
```ruby
gem 'affirm-ruby'
```
and `bundle install`.

*Note*: This gem is not yet registered with Rubygems. In the meantime, you can use the 'git' option in your Gemfile.

## Initialize
Initialize the client with your credentials (if you're using rails, this goes in `config/initializers`).
```ruby
Affirm::API.public_key = "xxx"
Affirm::API.secret_key = "xxx"
Affirm::API.api_url    = "https://sandbox.affirm.com/api/v2/"
```

## Charges
The charges resource can be accessed through the api class:
```ruby
Affirm::API.charges
```

### Authorizing a charge
```ruby
Affirm::API.charges.authorize(checkout_token: "token")
Affirm::API.charges.authorize!(checkout_token: "token") # raises Affirm::Error on failure
```

### Reading a charge
```ruby
Affirm::API.charges.get(charge_id: "abcd")
```

### Capturing a charge
Optionally takes an `order_id`, `shipping_carrier`, and `shipping_confirmation`.
```ruby
Affirm::API.charges.capture(charge_id: "abcd")
Affirm::API.charges.capture(charge_id: "abcd", order_id: "1234", shipping_carrier: "USPS", shipping_confirmation: "ABCD1234")
Affirm::API.charges.capture!(charge_id: "abcd") # raises Affirm::Error on failure
```

### Voiding a charge
```ruby
Affirm::API.charges.void(charge_id: "abcd")
Affirm::API.charges.void!(charge_id: "abcd") # raises Affirm::Error on failure
```

### Refunding a charge
Optionally takes an `amount` to refund (in cents).
```ruby
Affirm::API.charges.refund(charge_id: "abcd")
Affirm::API.charges.refund(charge_id: "abcd", amount: 5000)
Affirm::API.charges.refund!(charge_id: "abcd") # raises Affirm::Error on failure
```

### Updating tracking fields
Optionally takes an `order_id`, `shipping_carrier`, and `shipping_confirmation`.
```ruby
Affirm::API.charges.update(charge_id: "abcd", order_id: "1234", shipping_carrier: "USPS", shipping_confirmation: "ABCD1234")
Affirm::API.charges.update!(charge_id: "abcd", order_id: "1234") # raises Affirm::Error on failure
```

## Responses
On successful api calls, the response json is 
```ruby
response = Affirm::API.charges.get(charge_id: "abcd")

response.success? # => true
response.error? # => false

response.status_code # => 200

response.body # => hash of values
response.body["id"] # eg "abcd"
response.body["details"]["shipping_amount"] # eg 400
```

### Error responses
Unsuccessful responses have a few methods built in:
```ruby
response.code # eg "auth-declined"
response.type # eg "invalid_request"
response.message # eg "Invalid phone number format"
response.field # eg "shipping_address.phone"
```
See https://docs.affirm.com/v2/api/errors/#error-object.

### Exceptions
Exceptions are raised for 5xx, 404 and 401 responses, yielding an `Affirm::ServerError`,
`Affirm::ResourceNotFoundError` and `Affirm::AuthenticationError`, respectively. These are subclassed from
`Affirm::Error`.
```ruby
begin
  Affirm::API.charges.authorize(checkout_token: "token")
rescue Affirm::ServerError => e
  Logger.info e.code
  Logger.info e.message
end
```

## Running specs
After bundling, run `bundle exec rspec` to run the tests.

## License
Copyright 2015 Reverb.com, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
