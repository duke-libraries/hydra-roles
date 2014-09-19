require "hydra/roles/version"
require "active_triples"
require "hydra/validations"


module Hydra
  module Roles
    extend ActiveSupport::Concern

    module ClassMethods
      def configure
        yield self
      end
    end

  end
end

Dir[File.dirname(__FILE__) + "/roles/*.rb"].each { |file| require file }
