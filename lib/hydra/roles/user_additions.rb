module Hydra
  module Roles
    module UserAdditions

      def has_role? role, obj
        obj.roles.granted? role, user: self.user_key, group: self.groups, any: true
      end

    end
  end
end

if defined?(User) && User.is_a?(Class)
  User.class_eval do
    include Hydra::Roles::UserAdditions
  end
end
