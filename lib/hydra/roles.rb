require "hydra/roles/version"
require "active_triples"
require "active_support"

module Hydra
  module Roles
    extend ActiveSupport::Concern

    included do
      include Hydra::Roles::ModelAdditions
    end

  end
end

Dir[File.dirname(__FILE__) + "/roles/*.rb"].each { |file| require file }
