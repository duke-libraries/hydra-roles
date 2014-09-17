require "active_fedora"

module Hydra
  module Roles
    class RolesDatastream < ActiveFedora::RdfxmlRDFDatastream

      delegate :grant, :revoke, :show_grants, to: :resource

      def self.resource_class
        RolesResource
      end

    end
  end
end
