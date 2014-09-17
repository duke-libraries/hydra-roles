require 'rdf/isomorphic'

module Hydra
  module Roles
    class PrincipalResource < ActiveTriples::Resource

      include RDF::Isomorphic
      include Hydra::Validations

      configure type: RDF::FOAF.Agent
      property :name, predicate: RDF::FOAF.name

      validates_single_cardinality_of :name

      alias_method :==, :isomorphic_with?

      def to_s 
        name.first
      end

      def inspect
        "#<#{self.class}: \"#{self}\">"
      end

      def self.build(name)
        raise TypeError, "Name must be a string: #{name.inspect}" unless name.is_a?(String)
        new.tap { |p| p.name = name }
      end

    end
  end
end
