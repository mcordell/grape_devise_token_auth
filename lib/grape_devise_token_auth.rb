require 'grape_devise_token_auth/version'
require 'grape_devise_token_auth/middleware'
require 'grape_devise_token_auth/auth_helpers'
require 'grape_devise_token_auth/authorizer_data'
require 'grape_devise_token_auth/token_authorizer'
require 'grape_devise_token_auth/configuration'
require 'grape'

module GrapeDeviseTokenAuth
  def self.setup!(middleware = false)
    add_auth_strategy if middleware
  end

  def self.add_auth_strategy
    Grape::Middleware::Auth::Strategies.add(
      :grape_devise_token_auth,
      GrapeDeviseTokenAuth::Middleware,
      ->(options) { [options[:resource_class]] }
    )
  end
end
