module Hydra
  module Roles
    class RoleDef

      include ActiveModel::Validations
      include Hydra::Validations

      attr_reader :name
      attr_writer :label
      attr_accessor :permissions

      validates_presence_of :name
      validates_inclusion_of :permissions, in: Hydra::Roles::PERMISSIONS, strict: true

      def initialize(name)
        @name = name.to_sym
      end

      def freeze!
        permissions.freeze
        freeze
      end

      def label
        @label || name.to_s.titleize
      end

      def to_s
        label
      end

    end
  end
end
