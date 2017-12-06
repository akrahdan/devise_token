# DeviseToken
DeviseToken is a lightweight authentication gem based on devise and jwt gems.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'devise_token'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install devise_token
```

Finally, run the install generator:

```bash
$ rails g devise_token:install User auth

This generator accepts the following optional arguments:

| Argument | Default | Description |
|---|---|---|
| USER_CLASS | `User` | The name of the class to use for user authentication. |
| MOUNT_PATH | `auth` | The path at which to mount the authentication routes.

This will create the following:

* An initializer will be created at `config/initializers/devise_token.rb`

* A model will be created in the `app/models` directory. If the model already exists, a concern will be included at the top of the file.
## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
