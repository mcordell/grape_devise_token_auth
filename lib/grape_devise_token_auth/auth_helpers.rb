module GrapeDeviseTokenAuth
  module AuthHelpers
    def self.included(_base)
      Devise.mappings.keys.each do |mapping|
        define_method("current_#{mapping}") do
          warden.session_serializer.fetch(:user)
        end
      end
    end

    def warden
      @warden ||= env['warden']
    end

    def authenticated?(scope = :user)
      user_type = "current_#{scope}"
      return false unless respond_to?(user_type)
      !!send(user_type)
    end
  end
end
