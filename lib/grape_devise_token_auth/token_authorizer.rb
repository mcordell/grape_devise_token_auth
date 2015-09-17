module GrapeDeviseTokenAuth
  class TokenAuthorizer
    extend Forwardable

    def initialize(data, devise_interface)
      @data = data
      @devise_interface = devise_interface
    end

    def authenticate_from_token(mapping = nil)
      @resource_class = devise_interface.mapping_to_class(mapping)
      return nil unless resource_class
      return nil unless data.token_prerequisites_present?
      load_user_from_uid
      return nil unless user_authenticated?
      user
    end

    private

    attr_accessor :resource_class
    attr_reader :data, :resource, :user, :devise_interface
    def_delegators :@data, :warden, :uid, :token, :client_id

    def user_authenticated?
      user && user.valid_token?(token, client_id)
    end

    def load_user_from_uid
      @user = resource_class.find_by_uid(uid)
    end

    def correct_resource_type_logged_in?
      resource && resource.class == resource_class
    end
  end
end
