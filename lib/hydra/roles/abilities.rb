module Hydra
  module Roles
    module Abilities
      extend ActiveSupport::Concern

      included do
        self.ability_logic << :roles_permissions
      end

      def roles_permissions
        Hydra::Roles.role_defs.each_permission do |permission, roles|
          can permission, ActiveFedora::Base do |obj|
            obj.roles.granted? *roles, user: current_user.user_key, group: current_user.groups, any: true
          end
        end
      end

    end
  end
end

if defined?(Ability)
  Ability.include Hydra::Roles::Abilities
end
