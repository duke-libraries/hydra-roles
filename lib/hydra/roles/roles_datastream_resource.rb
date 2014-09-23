module Hydra
  module Roles
    class RolesDatastreamResource < RolesResource
      include ActiveFedora::Rdf::Persistence
    end
  end
end
