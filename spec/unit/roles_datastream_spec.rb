require 'spec_helper'

module Hydra
  module Roles
    RSpec.describe RolesDatastream do

      let(:obj) { ActiveFedora::Base.new }
      let(:ds) { described_class.new(obj.inner_object, nil) }

      describe "resource" do
        it "should be a RolesResource" do
          expect(ds.resource).to be_a RolesResource
        end
      end

      describe "delegation" do
        it "should delegate :grant to the resource" do
          expect(ds.resource).to receive(:grant).with(:owner, user: "bob")
          ds.grant :owner, user: "bob"
        end
        it "should delegate :revoke to the resource" do
          expect(ds.resource).to receive(:revoke).with(:owner, user: "bob")
          ds.revoke :owner, user: "bob"
        end
        it "should delegate :granted? to the resource" do
          expect(ds.resource).to receive(:granted?).with(:owner, user: "bob")
          ds.granted? :owner, user: "bob"
        end
        it "should delegate :show_grants to the resource" do
          expect(ds.resource).to receive(:show_grants)
          ds.show_grants
        end
      end

    end
  end
end 
