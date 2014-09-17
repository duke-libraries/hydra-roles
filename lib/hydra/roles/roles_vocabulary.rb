module Hydra
  module Roles
    class RolesVocabulary < RDF::StrictVocabulary("https://github.com/duke-libraries/hydra-roles/roles#")
      property :owner         
      property :administrator 
      property :content_writer
      property :metadata_writer
      property :contributor
      property :content_reader
      property :metadata_reader
    end
  end
end
