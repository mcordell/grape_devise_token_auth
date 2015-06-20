module GrapeDeviseTokenAuth
  class Middleware
    extend Forwardable

    def initialize(app, resource_name)
      @app = app
      @resource_name = resource_name
    end

    def call(env)
      setup(env)
      user = token_authorizer.authenticate_from_token(@resource_name)
      return unauthorized unless user
      @auth_headers = AuthHeaders.new(user, request_start, authorizer_data)
      sign_in_user(user)
      responses_with_auth_headers(*@app.call(env))
    end

    private
    attr_reader :authorizer_data, :token_authorizer, :resource, :request_start
    def_delegators :@authorizer_data, :warden, :token, :client_id

    def setup(env)
      @request_start    = Time.now
      @authorizer_data  = AuthorizerData.from_env(env)
      @token_authorizer = TokenAuthorizer.new(@authorizer_data)
    end

    def sign_in_user(user)
      # user already logged in from devise:
      return resource if resource
      @resource = user
      set_user_in_warden(:user, user)
    end

    #extracted and simplified from Devise
    def set_user_in_warden(scope, resource)
      scope    = Devise::Mapping.find_scope!(scope)
      warden.session_serializer.store(resource, scope)
    end

    def responses_with_auth_headers(status, headers, response)
      [
        status,
        headers.merge(@auth_headers.headers),
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
