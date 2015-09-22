module GrapeDeviseTokenAuth
  module AuthHelpers
    def self.included(_base)
      Devise.mappings.keys.each do |mapping|
        define_method("current_#{mapping}") do
          user = send("authenticate_#{mapping}")
          user
        end

        define_method("authenticate_#{mapping}") do
          authorizer_data  = AuthorizerData.from_env(env)
          devise_interface = DeviseInterface.new(authorizer_data)
          token_authorizer = TokenAuthorizer.new(authorizer_data,
                                                 devise_interface)
          user = token_authorizer.authenticate_from_token(mapping)
          user
        end

        define_method("authenticate_#{mapping}!") do
          user = send("authenticate_#{mapping}")
          fail Unauthorized unless user
          user
        end
      end
    end

    def authenticated?(scope = :user)
      user_type = "current_#{scope}"
      return false unless respond_to?(user_type)
      !!send(user_type)
    end
  end
end
