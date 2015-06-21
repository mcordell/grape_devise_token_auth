%w(version middleware auth_helpers authorizer_data unauthorized
   token_authorizer configuration auth_headers devise_interface).each  do |file|
     require "grape_devise_token_auth/#{file}"
   end

require 'grape'

module GrapeDeviseTokenAuth
  class << self
    extend Forwardable

    def_delegators :configuration, :batch_request_buffer_throttle, :change_headers_on_each_request

    def configuration
      @configuration ||= Configuration.new
    end

    def config
      yield(configuration)
    end

    def setup!(middleware = false)
      yield(configuration) if block_given?
      add_auth_strategy
    end

    def add_auth_strategy
      Grape::Middleware::Auth::Strategies.add(
        :grape_devise_token_auth,
        GrapeDeviseTokenAuth::Middleware,
        ->(options) { [options[:resource_class]] }
      )
    end
  end
end
