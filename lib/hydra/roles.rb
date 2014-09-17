require "hydra/roles/version"
require "active_triples"
require "hydra/validations"


module Hydra
  module Roles

  end
end

Dir[File.dirname(__FILE__) + "/roles/*.rb"].each { |file| require file }
