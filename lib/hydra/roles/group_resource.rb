require 'hydra/roles/principal_resource'

module Hydra
  module Roles
    class GroupResource < PrincipalResource
      configure type: RDF::FOAF.Group
    end
  end
end
