module GrapeDeviseTokenAuth
  class DeviseInterface
    def initialize(data)
      @warden = data.warden
      @client_id = data.client_id
    end

    # extracted and simplified from Devise
    def set_user_in_warden(scope, resource)
      scope = Devise::Mapping.find_scope!(scope)
      warden.session_serializer.store(resource, scope)
    end

    def mapping_to_class(m)
      mapping = m ? Devise.mappings[m] : Devise.mappings.values.first
      @resource_class = mapping.to
    end

    def exisiting_warden_user(resource_class)
      warden_user =  warden.user(resource_class.to_s.underscore.to_sym)
      return unless warden_user && warden_user.tokens[@client_id].nil?
      resource = warden_user
      resource.create_new_auth_token
      resource
    end

    private

    attr_reader :warden
  end
end
