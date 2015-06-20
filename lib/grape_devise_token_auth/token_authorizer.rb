module GrapeDeviseTokenAuth
  class TokenAuthorizer
    extend Forwardable

    def initialize(data)
      @data = data
    end

    def authenticate_from_token(mapping = nil)
      resource_class_from_mapping(mapping)
      return nil unless resource_class

      resource_from_existing_devise_user
      return resource if correct_resource_type_logged_in?

      return nil unless data.token_prerequisites_present?
      load_user_from_uid
      return nil unless user_authenticated?

      user
    end

    private

    attr_reader :data, :resource_class, :resource, :user
    def_delegators :@data, :warden, :uid, :token, :client_id

    def user_authenticated?
      user && user.valid_token?(token, client_id)
    end

    def load_user_from_uid
      @user = resource_class.find_by_uid(uid)
    end


    def resource_from_existing_devise_user
      warden_user =  warden.user(resource_class.to_s.underscore.to_sym)
      return unless warden_user && warden_user.tokens[client_id].nil?
      @resource = warden_user
      @resource.create_new_auth_token
    end

    def correct_resource_type_logged_in?
      resource && resource.class == resource_class
    end

    def resource_class_from_mapping(m)
      mapping = m ? Devise.mappings[m] : Devise.mappings.values.first
      @resource_class = mapping.to
    end
  end
end
