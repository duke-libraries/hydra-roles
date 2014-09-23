require "active_fedora"
require "hydra/roles/roles_resource"

module Hydra
  module Roles

    class RolesDatastream < ActiveFedora::RdfxmlRDFDatastream
      delegate :grant, :revoke, :show_grants, :granted?,  to: :resource

      def self.resource_class
        RolesDatastreamResource
      end
    end

  end
end
