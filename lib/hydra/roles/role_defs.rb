require 'singleton'

module Hydra
  module Roles
    class RoleDefs

      include Singleton

      attr_reader :role_defs

      def initialize
        @role_defs = {}
      end

      def define_role role, &block
        add_role_def RoleDefBuilder.build(role, &block)
      end

      def freeze!
        role_defs.freeze
        freeze
      end

      def add_role_def role_def
        raise "Role \"#{role_def.name}\" already defined." if role_defs.include?(role_def.name)
        role_defs[role_def.name] = role_def
      end

      def role_names
        role_defs.keys
      end

      def by_permissions
        permissions = {}
        role_defs.each do |role, role_def|
          role_def.permissions.each { |p| (permissions[p] ||= []) << role }
        end
        permissions
      end

      def method_missing(method, *args)
        return role_defs[method] if role_defs.include?(method)
        super
      end

    end
  end
end
