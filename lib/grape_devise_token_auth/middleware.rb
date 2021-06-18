module GrapeDeviseTokenAuth
  class Middleware
    extend Forwardable

    def initialize(app, resource_name)
      @app = app
      @resource_name = resource_name || app.options[:resource_class]
    end

    def call(env)
      setup(env)
      begin
        auth_all
        responses_with_auth_headers(*@app.call(env))
      rescue Unauthorized => _e
        return unauthorized
      end
    end

    private

    attr_reader :authorizer_data, :token_authorizer, :resource, :request_start
    def_delegators :@authorizer_data, :warden, :token, :client_id

    def auth_all
      return if skip_auth_all?
      user = token_authorizer.authenticate_from_token(@resource_name)
      fail Unauthorized unless user
      sign_in_user(user)
    end

    def skip_auth_all?
      !GrapeDeviseTokenAuth.configuration.auth_all?
    end

    def setup(env)
      @request_start    = Time.now
      @authorizer_data  = AuthorizerData.from_env(env)
      @devise_interface = DeviseInterface.new(@authorizer_data)
      @token_authorizer = TokenAuthorizer.new(@authorizer_data,
                                              @devise_interface)
    end

    def sign_in_user(user)
      @devise_interface.set_user_in_warden(@resource_name, user)
    end

    def responses_with_auth_headers(status, headers, response)
      auth_headers = AuthHeaders.new(warden, @resource_name, request_start, authorizer_data)
      [
        status,
        headers.merge(auth_headers.headers),
        response
      ]
    end

    def unauthorized
      [401,
       { 'Content-Type' => 'application/json'
       },
       []
      ]
    end
  end
end
