require 'active_triples'
require 'hydra/roles/roles_vocabulary'

module Hydra
  module Roles
    class RolesResource < ActiveTriples::Resource

      RolesVocabulary.each do |term|
        property term.label, predicate: term
      end

      def inspect
        "#<#{self.class}: #{to_hash}>"
      end

      def show_grants
        to_hash
      end

      # grant :searcher, users: ["bob", "sally"], groups: "public"
      # Grants role to principals
      def grant role, opts={}
        unless opts[:users].present? || opts[:groups].present?
          raise ArgumentError, "Options must include at least one of [:users, :groups]" 
        end
        to_grant = principals_for(opts)
        granted = send(role)
        unless granted.empty?
          to_grant.reject! { |principal| granted.include?(principal) }
        end
        return false if to_grant.empty?
        send(role) << to_grant
        to_grant
      end
      
      # revoke :owner, users: ["bob", "sally"], groups: "managers"
      # Revokes role from principals
      def revoke role, opts={}
        unless opts[:users].present? || opts[:groups].present?
          raise ArgumentError, "Options must include at least one of [:users, :groups]" 
        end
        granted = send(role)
        return false if granted.empty?
        to_revoke = principals_for(opts)
        return false if to_revoke.empty?
        revoked = granted.select { |principal| to_revoke.include?(principal) }
        send(role).delete(*revoked)
        revoked
      end

      def roles
        fields
      end

      def to_hash
        roles.each_with_object({}) do |role, h|
          granted = send(role)
          h[role] = {
            users: granted.select { |principal| principal.is_a?(UserResource) },
            groups: granted.select { |principal| principal.is_a?(GroupResource) }
          }
        end
      end

      private

      def user_principals_for(names)
        Array(names).map { |n| n.is_a?(UserResource) ? n : UserResource.build(n) }
      end

      def group_principals_for(names)
        Array(names).map { |n| n.is_a?(GroupResource) ? n : GroupResource.build(n) }
      end

      def principals_for(opts)
        user_principals_for(opts[:users]) + group_principals_for(opts[:groups])
      end

    end
  end
end
