# DynamicsCRM

[![Build Status](https://travis-ci.org/TinderBox/dynamics_crm.png)](https://travis-ci.org/TinderBox/dynamics_crm)

Ruby library for accessing Microsoft Dynamics CRM Online 2011/2013 via their SOAP API.

## Installation

Add this line to your application's Gemfile:

    gem 'dynamics_crm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dynamics_crm

## Usage


#### Username/Password authentication

```ruby
client = DynamicsCRM::Client.new({organization_name: "orgname"})
client.authenticate('user@orgname.onmicrosoft.com', 'password')
```

### retrieve

```ruby
client.retrieve('account', '53291AAB-4A9A-E311-B097-6C3BE5A8DD60')
# => #<DynamicsCRM::XML::Entity ... >
```

### retrieve_multiple

```ruby
client.retrieve_multiple('account', [["name", "Equal", "Test Account"]])
# => [#<DynamicsCRM::XML::Entity ... >]

client.retrieve_multiple('account', [["name", "Equal", "Test Account"], ["Name, "CreatedBy"]])
# => [#<DynamicsCRM::XML::Entity ... >]
```


### create

```ruby
# Add a new account
client.create('account', name: 'Foobar Inc.')
# => {id: '53291AAB-4A9A-E311-B097-6C3BE5A8DD60'}

# Add a new contact
client.create('contact', firstname: 'John', lastname: 'Doe', emailaddress1: "johndoe@mydomain.com")
# => {id: '71ef2416-50f7-e311-93fc-6c3be5a8c054'}
```

### update

```ruby
# Update the Account with id '53291AAB-4A9A-E311-B097-6C3BE5A8DD60'
client.update('account', '53291AAB-4A9A-E311-B097-6C3BE5A8DD60', name: 'Whizbang Corp')
# => {}
```

### delete

```ruby
# Delete the Account with id '53291AAB-4A9A-E311-B097-6C3BE5A8DD60'
client.delete('account', '53291AAB-4A9A-E311-B097-6C3BE5A8DD60')
# => {}
```

### retrieve_all_entities

```ruby
# get the list of organization entities
client.retrieve_all_entities
# => [#<DynamicsCRM::Metadata::EntityMetadata>, ...]
```

### retrieve_entity

```ruby
# get the entity metadata for the account object
client.retrieve_entity('account')
# => DynamicsCRM::Metadata::EntityMetadata
```

### retrieve_attribute

```ruby
# get AttributeMetadata for 'name' field on the account object
client.retrieve_attribute('account', 'name')
# => [#<DynamicsCRM::Metadata::AttributeMetadata>, ...]
```

### associate a contact to an account

```ruby
contacts = [ DynamicsCRM::XML::EntityReference.new("contact", contact["id"])]
client.associate("account", account["id"], "contact_customer_accounts", contacts)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
