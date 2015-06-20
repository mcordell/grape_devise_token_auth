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
      sign_in_user(user)
      responses_with_auth_headers(*@app.call(env))
    end

    private

    def_delegators :@authorizer_data, :warden, :token, :client_id
    attr_reader :authorizer_data, :token_authorizer, :resource, :request_start

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
        headers.merge(auth_headers),
        response
      ]
    end

    def auth_headers
      return {} unless resource && resource.valid? && client_id
      auth_headers_from_resource
    end

    def auth_headers_from_resource
      auth_headers = {}
      resource.with_lock do
        if !DeviseTokenAuth.change_headers_on_each_request
          auth_headers = resource.extend_batch_buffer(token, client_id)
        elsif batch_request?
          resource.extend_batch_buffer(token, client_id)
          # don't set any headers in a batch request
        else
          auth_headers = resource.create_new_auth_token(client_id)
        end
      end
      auth_headers
    end

    def unauthorized
      [401,
       { 'Content-Type' => 'application/json'
       },
       []
      ]
    end

    def batch_request?
      @batch_request ||= resource.tokens[client_id] &&
                         resource.tokens[client_id]['updated_at'] &&
                         within_batch_request_window?
    end

    def within_batch_request_window?
      end_of_window = Time.parse(resource.tokens[client_id]['updated_at']) +
                      DeviseTokenAuth.batch_request_buffer_throttle
      request_start < end_of_window
    end
  end
end
