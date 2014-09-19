require 'active_triples'
require 'hydra/roles/roles_vocabulary'

module Hydra
  module Roles
    class RolesResource < ActiveTriples::Resource

      RolesVocabulary.each do |term|
        property term.label, predicate: term
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

      # Grants role to one or more principals
      #
      # @param role [Symbol] the role to grant
      # @param opts [Hash] grant options 
      #   Keys must include one of `:user` or `:group`.
      #   Values may be strings or arrays of principal names.
      # @return [Array] list of principals to which the role has been granted
      #
      def grant role, opts={}
        validate_opts!(opts)
        to_grant = extract_principals(opts)
        granted = principals_granted(role)
        unless granted.empty?
          to_grant.reject! { |principal| granted.include?(principal) } 
        end
        return false if to_grant.empty?
        granted << to_grant
        to_grant
      end

      # Revokes role from one or more principals      
      #
      # @param role [Symbol] the role to revoke
      # @param opts [Hash] revoke options 
      #   Keys must include one of `:user` or `:group`.
      #   Values may be strings or arrays of principal names.
      # @return [Array] list of principals from which the role has been revoked
      #
      def revoke role, opts={}
        validate_opts!(opts)
        to_revoke = extract_principals(opts)
        granted = principals_granted(role)
        return false if granted.empty?
        # This might seem unintuitive, but `delete` doesn't respect isomorphism
        # so we have to select the nodes from the resource.
        # `include?`, however, compares using `==` which aliases `isomorphic_with?`
        # in Hydra::Roles::PrincipalResource.
        to_revoke = granted.select { |principal| to_revoke.include?(principal) }
        return false if to_revoke.empty?
        granted.delete(*to_revoke)
        to_revoke
      end

      def show_grants
        to_hash
      end

      #
      # granted? :owner, user: "bob", group: ["managers", "admins"]
      # => true if all principals have been granted the role, else false
      #
      # granted? :owner, user: "bob", group: ["managers", "admins"], any: true
      # => true if any of the principals have been granted the role, else false
      #
      def granted? role, opts={}
        validate_opts!(opts)
        any = !!opts[:any]
        [:user, :group].each do |type|
          next unless opts[type].present?
          names_granted = principal_names_granted(role, type)
          if any
            return true if Array(opts[type]).any? { |name| names_granted.include?(name) }
          else
            return false unless Array(opts[type]).all? { |name| names_granted.include?(name) }
          end
        end
        !any
      end

      def principals_granted role, type=nil
        principals = send(role)
        return principals unless type
        principals.select { |p| p.is_a?(principal_resource(type)) }
      end

      def principal_names_granted role, type
        principals_granted(role, type).map(&:name).flatten
      end
      
      def roles
        fields
      end

      def to_hash
        roles.each_with_object({}) do |role, h|
          h[role] = [:user, :group].each_with_object({}) do |type, i|
            names_granted = principal_names_granted(role, type)
            i[type] = names_granted if names_granted.present?
          end
        end
      end

      def principal_resource(type)
        Object.const_get "Hydra::Roles::#{type.to_s.capitalize}Resource"
      end

      def principal_rdf_type(type)
        principal_resource(type).send(:type)
      end

      def extract_principals(opts)
        [:user, :group].map { |type| principals_for(opts[type], principal_resource(type)) }.flatten
      end

      def principal_for(name, principal_type)
        name.is_a?(principal_type) ? name : principal_type.build(name)
      end

      def principals_for(names, principal_type)
        Array(names).map { |n| principal_for(n, principal_type) }
      end

      def validate_opts!(opts)
        unless [:user, :group].any? { |o| opts[o].present? }
          raise ArgumentError, "`:user' or `:group' option must be present." 
        end
      end

    end
  end
end
