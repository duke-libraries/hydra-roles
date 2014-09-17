module Hydra
  module Roles
    class UserResource < PrincipalResource
      configure type: RDF::FOAF.Person
    
      def user
        User.find_by_user_key(name.first)
      end
    end
  end
end
