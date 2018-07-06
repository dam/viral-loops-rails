# VLoopsRails

* Implementing a client for the Viral Loops API


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'viral-loops-rails', git: 'https://github.com/dam/viral-loops-rails', require: 'viral_loops_rails'
```

And then execute:

    $ bundle install
    
Then, create an initializer in your Rails application with the following code:

```ruby
require 'viral_loops_rails'

VLoopsRails.configure(api_token: 'token', campaign_id: 'campaign_id'])
```

## How to integrate the widgets in your application

You can include helpers directly in your template:

```erb
<%= vloops_script_tag(type: :refer_a_friend, position: 'top-right') %>
```

Or add filters in your controllers:

```ruby
after_action only: :new do
  vloops_rails_auto_include(type: :refer_a_friend, position: 'top-right')
end
```
    
## Widgets currently implemented

* [Refer a Friend launcher](https://intercom.help/viral-loops/refer-a-friend/installation-instructions/refer-a-friend-html)


## Usage of the API client

Configure the client:

```ruby
VLoopsRails.configure(api_token: 'your_api_token')
```

Then you can use the API:

```ruby
client = VLoopsRails::Client.new
client.scroll_pending_rewards.each do |reward|
  p reward
end
```

Please look at the code inside the _spec/_ folder for examples.

## API endpoint currently implemented

* [Refer a friend endpoints](https://intercom.help/viral-loops/refer-a-friend/refer-a-friend-http-api-reference)
* [Reward endpoints](https://intercom.help/viral-loops/refer-a-friend/api-rewarding)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dam/viral-loops-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Viral::Loops::Rails project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dam/viral-loops-rails/blob/master/CODE_OF_CONDUCT.md).
