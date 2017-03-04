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

client.retrieve_multiple('account', [["name", "Equal", "Test Account"], ['salesstage', 'In', [0, 1, 2]]])
# => [#<DynamicsCRM::XML::Entity ... >]

client.retrieve_multiple('account', [["telephone1", "EndsWith", "5558675309"], ["mobilephone", "EndsWith", "5558675309"]], [], "Or")
# => [#<DynamicsCRM::XML::Entity ... >]
```

### retrieve_multiple using QueryExpression

```ruby
# Build QueryExpression
query = DynamicsCRM::XML::QueryExpression.new('account')
query.columns = %w(accountid name)
query.criteria.add_condition('name', 'NotEqual', 'Test Account')
# Optional PageInfo
query.page_info = DynamicsCRM::XML::PageInfo.new(count: 5, page_number: 1, return_total_record_count: true)

# Get first page
result = client.retrieve_multiple(query)

while result.MoreRecords
  # Next page
  query.page_info.page_number += 1
  query.page_info.paging_cookie = result.PagingCookie

  result = client.retrieve_multiple(query)
end
```

### retrieve_multiple using complex Filters

```ruby
# Build QueryExpression
query = DynamicsCRM::XML::QueryExpression.new('account')
query.columns = %w(accountid name telephone1)
# Switch to Or criteria
query.criteria.filter_operator = 'Or'

filter1 = DynamicsCRM::XML::FilterExpression.new('And')
filter1.add_condition('name', 'Equal', 'Integration Specialists')
filter1.add_condition('telephone1', 'In', ['(317) 845-2212', '3178452212'])

filter2 = DynamicsCRM::XML::FilterExpression.new('And')
filter2.add_condition('name', 'Equal', 'Thematics Development Inc.')
filter2.add_condition('telephone1', 'Null')

# Add Filters to criteria
query.criteria.add_filter(filter1)
query.criteria.add_filter(filter2)


result = client.retrieve_multiple(query)
```


### fetch (FetchXml)

```ruby
# Raw XML Support
xml = %Q{<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="opportunityproduct">
    <attribute name="opportunityproductid" />
    <attribute name="productdescription" />
    <attribute name="priceperunit" />
    <attribute name="quantity" />
    <order attribute="productid" descending="false" />
    <link-entity name="product" from="productid" to="productid" alias="product" link-type="inner">
      <attribute name="name" />
      <attribute name="producttypecode" />
      <attribute name="price" />
      <attribute name="standardcost" />
    </link-entity>
    <filter type="and">
      <condition attribute="opportunityid" operator="eq" value="02dd7344-d04a-e411-a9d3-9cb654950300" />
    </filter>
  </entity>
</fetch>}

result = client.fetch(xml)
# => #<DynamicsCRM::XML::EntityCollection>
# result.entity_name => 'opportunityproduct'
# result.entities => [DynamicsCRM::XML::Entity, ...]
```

```ruby
# Using FetchXml::Builder
builder = DynamicsCRM::FetchXml::Builder.new()

entity = builder.entity('opportunityproduct').add_attributes(
  ['productdescription', 'priceperunit', 'quantity', 'opportunityproductid']
).order('productid')

entity.link_entity('product', to: 'productid', from: 'productid', :alias => 'product').add_attributes(
  ['name', 'producttypecode', 'price', 'standardcost']
)

entity.add_condition('opportunityid', 'eq', '02dd7344-d04a-e411-a9d3-9cb654950300')

result = client.fetch(builder.to_xml)
# => #<DynamicsCRM::XML::EntityCollection>
# result.entity_name => 'opportunityproduct'
# result.entities => [DynamicsCRM::XML::Entity, ...]
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

## Logging

If you want to log the REQUEST and RESPONSE, you can do through [Logger](http://www.ruby-doc.org/stdlib-2.1.2/libdoc/logger/rdoc/Logger.html) class of Ruby.

```ruby
client.logger = Logger.new(STDOUT)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
