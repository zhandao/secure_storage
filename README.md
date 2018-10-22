# SecureStorage

Transparent Encryption Storage. 
It helps you automatically decrypt the fields you declared when they are saved and read.

It use **Base64 encoded, AES256-CBC encrypt** by default (can not change currently).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'secure_storage', github: 'zhandao/secure_storage'
```

## Usage

### Config

In your model:

```ruby
self.secure_storage_key = Settings.secure_storage.key
# self.prefix = 'encrypted_' # prefix for the columns name
# self.suffix = ''           # suffix for the columns name
```

### Migration

Change the fields' column name, as default:

```ruby
t.string :encrypted_email
```

### Declare

In your model:

```ruby
has_secure :email#, :phone, ...
```

### Old Data Processing

```ruby
Model.secure_storage
```

Note: Unencrypted data will be encrypted automatically when read it.

### Try It!

```ruby
Model.create(email: 'test@test.com')
Model.first.email           # => 'test@test.com'
Model.first.encrypted_email # => 'ENCRYPTED'
```

### Querying

```ruby
Model.find_by_email('test@test.com')         # ok
Model.find(email: 'test@test.com')           # NO!
Model.where(encrypted_email: 'ENCRYPTED')    # ok
Model.with_encrypted(email: 'test@test.com') # ok
Model.xwhere(email: 'test@test.com')         # ok
```

Suppose we have another encrypted `phone`:

```ruby
Model.xfind_by(email: 'test@test.com', phone: '123', not_enc_filed: 'foo')
Model.xwhere(email: 'test@test.com', phone: '123', not_enc_filed: 'foo')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/secure_storage. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SecureStorage project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/secure_storage/blob/master/CODE_OF_CONDUCT.md).
