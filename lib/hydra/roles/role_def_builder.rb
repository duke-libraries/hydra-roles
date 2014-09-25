module Hydra
  module Roles
    class RoleDefBuilder

      attr_reader :role_def
      
      def self.build role, &block
        builder = new(role)
        builder.instance_eval &block
        builder.role_def.valid?
        builder.role_def.freeze!
        builder.role_def
      end

      def initialize role
        @role_def = RoleDef.new(role)
      end

      def label arg
        role_def.label = arg
      end

      def permissions *args
        role_def.permissions = args
      end

    end
  end
end
