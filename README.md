# GrapeDeviseTokenAuth

GrapeDeviseTokenAuth gem is a compatability layer between
[devise_token_auth][1] and [grape][2]. It is useful when mounting a grape API
in a rails application where [devise][3] (or `devise_token_auth` + `devise`)
is already present. It is reliant on `devise_token_auth` and `devise`,
therefore it is not suitable for grape where these are not present.

The majority of the hard work and credit goes to [Lyann Dylan
Hurley][4] and his fantistic [devise_token_auth][1] gem.
I merely have ported this to work well with grape.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape_devise_token_auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape_devise_token_auth

## Usage

Place this line in an initializer in your rails app or at least somewhere before
the grape API will get loaded:

```ruby
GrapeDeviseTokenAuth.setup!
```

Within the Grape API:

```
class Posts < Grape::API
  auth :grape_devise_token_auth, resource_class: :user

  helpers GrapeDeviseTokenAuth::AuthHelpers

  # ...
end
```

The resource class option allows you to specific the scope that will be
authenticated, this corresponds to your devise mapping.

Individual endpoints can now be authenticated by calling `authenticate_YOUR_MAPPING_HERE!` (e.g. `authenticate_user!`)
within them.

For Example:

```
get '/' do
  authenticate_user!
  present Post.all
end
```

alternatively to protect all routes place the call in a before block:

```
before do
  authenticate_user!
end
```

There is also a `authenticate_user` version of this helper (notice that it lacks of exclamation mark) that doen't fail nor returns 401.

[A full example setup can be found here][6]

## Testing and Example

Currently I am using [this repo][5] to test this gem, eventually I plan on
migrating the tests into the `grape_devise_token_auth` repo. For now though, I
refer you to that repo for how to integrate with an existing `devise` and
`devise_token_auth` repo.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/grape_devise_token_auth/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[1]: https://github.com/lynndylanhurley/devise_token_auth
[2]: https://github.com/intridea/grape
[3]: https://github.com/plataformatec/devise
[4]: https://github.com/lynndylanhurley
[5]: https://github.com/mcordell/rails_grape_auth
[6]: https://github.com/mcordell/rails_grape_auth/blob/7ca6b2f3d989fc23824aaf40fc353fc3e8de40ec/app/api/grape_api/posts.rb
