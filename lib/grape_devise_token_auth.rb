%w(version middleware auth_helpers authorizer_data
   token_authorizer configuration auth_headers devise_interface).each  do |file|
     require "grape_devise_token_auth/#{file}"
   end

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
