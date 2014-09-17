require 'spec_helper'

module Hydra
  module Roles
    RSpec.describe RolesResource do
      subject { described_class.new }
      describe "#grant" do
        context "with :users option" do
          before { subject.owner << UserResource.build("bob") }
          it "should add users to the role who do not already have the role" do
            subject.grant :owner, users: ["bob", "sally"]
            expect(subject.owner.map(&:to_s)).to match_array ["bob", "sally"]
          end
        end
        context "with :groups option" do
          before { subject.owner << GroupResource.build("admins") }
          it "should add groups to the role that do not already have the role" do
            subject.grant :owner, groups: ["admins", "managers"]
            expect(subject.owner.map(&:to_s)).to match_array ["admins", "managers"]
          end
        end
        context "no :users or :groups option" do
          it "should raise an exception" do
            expect { subject.grant :owner }.to raise_error
          end
        end
      end
      describe "#revoke" do
        context "with :users option" do
          before { subject.grant :owner, users: ["bob", "sally"] }
          it "should remove users from the role" do
            subject.revoke :owner, users: "sally"
            expect(subject.owner.map(&:to_s)).to eq ["bob"]
          end
        end
        context "with :groups option" do
          before { subject.grant :owner, groups: ["admins", "managers"] }
          it "should remove groups from the role" do
            subject.revoke :owner, groups: "managers"
            expect(subject.owner.map(&:to_s)).to eq ["admins"]
          end
        end
        context "no :users or :groups option" do
          it "should raise an exception" do
            expect { subject.revoke :owner }.to raise_error
          end
        end
      end
      describe "#roles" do
        it "should be equivalent to the list of fields" do
          expect(subject.roles).to match_array(subject.fields)
        end
      end
    end
  end
end
