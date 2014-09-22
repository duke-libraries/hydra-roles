module Hydra
  module Roles
    class RolesVocabulary < RDF::StrictVocabulary("https://github.com/duke-libraries/hydra-roles/roles#")
      property :owner,           label: "Owner"
      property :administrator,   label: "Curator"
      property :content_writer,  label: "Editor"
      property :metadata_writer, label: "Metadata Editor"
      property :contributor,     label: "Contributor"
      property :content_reader,  label: "Downloader"
      property :metadata_reader, label: "Reader"
    end
  end
end
