module GrapeDeviseTokenAuth
  class AuthHeaders
    extend Forwardable

    def initialize(resource, request_start, data)
      @resource = resource
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
      end_of_window = Time.parse(resource.tokens[client_id]['updated_at']) +
                      GrapeDeviseTokenAuth.batch_request_buffer_throttle

      request_start < end_of_window
    end

    def auth_headers_from_resource
      auth_headers = {}
      resource.with_lock do
        if !GrapeDeviseTokenAuth.change_headers_on_each_request
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
  end
end
