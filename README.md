# affirm-ruby

Ruby client library for integrating with Affirm financing (https://www.affirm.com/)

Requires Ruby 2.1 or greater.

[![Build Status](https://travis-ci.org/justqyx/affirm-ruby.png?branch=master)](https://travis-ci.org/justqyx/affirm-ruby)

## Install

Add to your gemfile:

```ruby
gem 'affirm'
```

and `bundle install`.

## Initialize

You should instantiate a Affirm::ChargeGateway object before creating/retrieving a charge. This is useful when your system has multiple Affirm accounts.

```ruby
charge_gateway = Affirm::ChargeGateway.new(
  environment: 'live', # or sandbox
  public_key: 'xxxx',
  secret_key: 'xxxx'
)
```

## Charges

All API requests raise an `Affirm::Error` or subclass thereof on failure.

### Creating/authorizing a charge

```ruby
charge = charge_gateway.create('checkout_token')
```

### Retrieving a charge

```ruby
charge = charge_gateway.retrieve("ABCD-ABCD")

charge.id
charge.amount
charge.created
charge.currency
charge.auth_hold
charge.payable
charge.void?
charge.order_id
charge.events    # array of Affirm::ChargeEvent
charge.details   # hash of order details
```

Raises an `Affirm::ResourceNotFoundError` if the charge doesn't exist.

See https://docs.affirm.com/v2/api/charges/#charge-object for more info on the charge object

### Capturing a charge
Optionally takes an `order_id`, `shipping_carrier`, and `shipping_confirmation`.

```ruby
charge.capture
charge.capture(order_id: "1234", shipping_carrier: "USPS", shipping_confirmation: "ABCD1234")
```

Returns an `Affirm::ChargeEvent` object of type `capture`.

### Voiding a charge

```ruby
charge.void
```

Returns an `Affirm::ChargeEvent` object of type `void`.

### Refunding a charge
Optionally takes an `amount` to refund (in cents).

```ruby
charge.refund
charge.refund(amount: 1000)
```

Returns an `Affirm::ChargeEvent` object of type `refund`.

### Updating tracking fields
Optionally takes an `order_id`, `shipping_carrier`, and `shipping_confirmation`.

```ruby
charge.update(order_id: "1234", shipping_carrier: "USPS", shipping_confirmation: "ABCD1234")
```

Returns an `Affirm::ChargeEvent` object of type `update`.

## Exceptions
Errors due to failed requests with the charges api (ie http code 400) will raise an `Affirm::ChargeError`.

Special exceptions are raised for 5xx, 404 and 401 responses, yielding an `Affirm::ServerError`,
`Affirm::ResourceNotFoundError` and `Affirm::AuthenticationError`, respectively. These are all subclassed from
`Affirm::Error`.

All exceptions have the following methods on them:

```ruby
begin
  charge_gateway.create("checkout_token")
rescue Affirm::Error => e
  Logger.info e.http_code # eg 422
  Logger.info e.code      # eg "auth-declined"
  Logger.info e.message   # eg "Invalid phone number format"
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
