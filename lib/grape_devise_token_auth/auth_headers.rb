module GrapeDeviseTokenAuth
  class AuthHeaders
    extend Forwardable

    def initialize(warden, mapping, request_start, data)
      @resource = warden.user(:user)
      @request_start = request_start
      @data = data
    end

    def headers
      return {} unless resource && resource.valid? && client_id
      auth_headers_from_resource
    end

    private

    def_delegators :@data, :token, :client_id
    attr_reader :request_start, :resource

    def batch_request?
      @batch_request ||= resource.tokens[client_id] &&
                         resource.tokens[client_id]['updated_at'] &&
                         within_batch_request_window?
    end

    def within_batch_request_window?
      end_of_window = Time.parse(resource.tokens[client_id]['updated_at'].to_s) +
                      GrapeDeviseTokenAuth.batch_request_buffer_throttle

      request_start < end_of_window
    end

    def auth_headers_from_resource
      if !GrapeDeviseTokenAuth.change_headers_on_each_request
        return {} if resource.reload.tokens[client_id].nil?
        resource.build_auth_header(token, client_id)
      else
        resource.with_lock do
          return {} if resource.tokens[client_id].nil?
          if batch_request?
            auth_headers = resource.extend_batch_buffer(token, client_id)
            auth_headers[DeviseTokenAuth.headers_names[:"access-token"]] = ' '
            auth_headers[DeviseTokenAuth.headers_names[:"expiry"]] = ' '
            auth_headers
          else
            resource.create_new_auth_token(client_id)
          end
        end
      end
    end
  end
end
