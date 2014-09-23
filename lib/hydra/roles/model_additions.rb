module Hydra
  module Roles
    module ModelAdditions
      extend ActiveSupport::Concern

      included do
        has_metadata "roles", type: RolesDatastream, control_group: "M", versionable: true
      end

    end
  end
end
