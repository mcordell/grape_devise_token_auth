module GrapeDeviseTokenAuth
  class DeviseInterface
    def initialize(data)
      @client_id = data.client_id
    end

    def mapping_to_class(m)
      mapping = m ? Devise.mappings[m] : Devise.mappings.values.first
      @resource_class = mapping.to
    end
  end
end
