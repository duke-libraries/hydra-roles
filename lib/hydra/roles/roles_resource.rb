require 'active_support/core_ext/array/extract_options'
require 'active_triples'

module Hydra
  module Roles
    class RolesResource < ActiveTriples::Resource

      Hydra::Roles.role_defs do |role|
        property role.name, predicate: role.uri
      end

      def self.from_hash roles_hash
        new.tap do |roles|
          roles_hash.each do |role, opts|
            roles.grant role, opts if opts.present?
          end
        end
      end

      def ==(other)
        to_hash == other.to_hash
      end

      def to_s
        to_hash
      end

      def inspect
        "#<#{self.class}: #{to_hash}>"
      end

      # Grants roles to one or more principals
      #
      # @return [RolesResource] self
      def grant *args
        opts = extract_options!(args)
        principals = extract_principals(opts)
        args.each { |role|  grant_role_to_principals(role, principals) }
        self
      end

      # Revokes roles from one or more principals      
      #
      # @return [RolesResource] self
      def revoke *args
        opts = extract_options!(args)
        principals = extract_principals(opts)
        args.each { |role| revoke_role_from_principals(role, principals) }
        self
      end

      def show_grants
        to_hash
      end

      # Return true if the roles have been granted to the principals
      #
      # By default, returns true if and only if all roles have been granted to all principals.
      # With `:any_role=>true` option, returns true if any role has been granted to (all) the principals.
      # With `:any_principal=>true` option, returns true if any principal has been granted (all) the roles.
      # With `:any=>true` -- or `:any_role=>true, :any_principal=>true` -- returns true if any role 
      # has been granted to any principal.
      def granted? *args
        opts = extract_options!(args)
        principals = extract_principals(opts)
        any_role = opts[:any_role] || opts[:any]
        any_principal = opts[:any_principal] || opts[:any]
        args.send(any_role ? :any? : :all?) do |role| 
          role_granted_to_principals?(role, principals, any: any_principal) 
        end
      end

      def principals_granted role, type=nil
        principals = send(role)
        return principals unless type
        principals.select { |p| p.is_a?(principal_resource(type)) }
      end
      
      def roles
        fields
      end

      def to_hash
        roles.each_with_object({}) do |role, h|
          h[role] = [:user, :group].each_with_object({}) do |type, i|
            granted = principals_granted(role, type)
            i[type] = granted.map(&:to_s) unless granted.empty?
          end
        end
      end

      protected

      def principal_resource(type)
        Object.const_get "Hydra::Roles::#{type.to_s.capitalize}Resource"
      end

      def principal_rdf_type(type)
        principal_resource(type).send(:type)
      end

      def principal_for(name, principal_type)
        name.is_a?(principal_type) ? name : principal_type.build(name)
      end

      def principals_for(names, principal_type)
        Array(names).map { |n| principal_for(n, principal_type) }
      end

      def role_granted_to_principals? role, principals, opts={}
        granted = principals_granted(role)
        test = opts[:any] ? :any? : :all?
        principals.send(test) { |principal| granted.include?(principal) }
      end

      def grant_role_to_principals role, principals
        granted = principals_granted(role)
        grantees = granted.empty? ? principals.dup : principals.reject { |principal| granted.include?(principal) } 
        granted << grantees unless grantees.empty?
      end

      def revoke_role_from_principals role, principals
        granted = principals_granted(role)
        unless granted.empty?
          # This might seem unintuitive, but `delete` doesn't respect isomorphism
          # so we have to select the nodes from the resource.
          # `include?`, however, compares using `==` which aliases `isomorphic_with?`
          # in Hydra::Roles::PrincipalResource.
          revokees = granted.select { |principal| principals.include?(principal) }
          granted.delete(*revokees) unless revokees.empty? 
        end
      end

      def extract_options!(args)
        opts = args.extract_options!
        return opts if [:user, :group].any? { |o| opts[o].present? }
        raise ArgumentError, "`:user' or `:group' option must be present." 
      end
      
      def extract_principals(opts)
        [:user, :group].map { |type| principals_for(opts[type], principal_resource(type)) }.flatten
      end

    end
  end
end
