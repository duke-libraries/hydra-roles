require "hydra/roles/version"
require "hydra/roles/role_defs"
require "active_triples"
require "active_support"

module Hydra
  module Roles

    PERMISSIONS = [:manage, :upload, :add_children, :edit_metadata, :edit, :download, :read].freeze

    def self.role_defs
      RoleDefs.instance
    end

    def self.define_roles &block
      role_defs.instance_eval &block
      role_defs.freeze!        
    end

  end
end

Dir[File.dirname(__FILE__) + "/roles/*.rb"].each { |file| require file }

Hydra::Roles.define_roles do

  define_role :owner do
    permissions :manage
  end

  define_role :administrator do
    label "Curator"
    permissions :manage
  end

  define_role :contributor do
    permissions :add_children
  end

  define_role :content_writer do
    label "Editor"
    permissions :upload
  end

  define_role :metadata_writer do
    label "Metadata Editor"
    permissions :edit_metadata
  end

  define_role :content_reader do
    label "Downloader"
    permissions :download
  end

  define_role :metadata_reader do
    label "Reader"
    permissions :read
  end

end
