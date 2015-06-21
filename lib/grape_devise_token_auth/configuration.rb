module GrapeDeviseTokenAuth
  class Configuration
    attr_accessor :batch_request_buffer_throttle, :change_headers_on_each_request, :authenticate_all
    ACCESS_TOKEN_KEY = 'HTTP_ACCESS_TOKEN'
    EXPIRY_KEY = 'HTTP_EXPIRY'
    UID_KEY = 'HTTP_UID'
    CLIENT_KEY = 'HTTP_CLIENT'

    def initialize
      @batch_request_buffer_throttle  ||= DeviseTokenAuth.batch_request_buffer_throttle
      @change_headers_on_each_request ||= DeviseTokenAuth.change_headers_on_each_request
      @authenticate_all = true
    end
  end
end
