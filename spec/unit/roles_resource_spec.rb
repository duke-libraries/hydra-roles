require 'spec_helper'

module Hydra
  module Roles
    RSpec.describe RolesResource do

      subject { described_class.new }

      describe "#grant" do
        context "with :user option" do
          before { subject.owner << UserResource.build("bob") }
          it "should add users to the role who do not already have the role" do
            subject.grant :owner, user: ["bob", "sally"]
            expect(subject.owner.map(&:to_s)).to match_array ["bob", "sally"]
          end
        end
        context "with :group option" do
          before { subject.owner << GroupResource.build("admins") }
          it "should add groups to the role that do not already have the role" do
            subject.grant :owner, group: ["admins", "managers"]
            expect(subject.owner.map(&:to_s)).to match_array ["admins", "managers"]
          end
        end
        context "no :user or :group option" do
          it "should raise an exception" do
            expect { subject.grant :owner }.to raise_error
          end
        end
      end

      describe "#granted?" do
        before { subject.grant :owner, user: "sally", group: ["admins", "managers"] }
        context "default behavior" do
          it "should return true if and only if all principals have been granted the role" do
            expect(subject.granted? :owner, user: "sally").to be true
            expect(subject.granted? :owner, group: "admins").to be true
            expect(subject.granted? :owner, group: ["admins", "managers"]).to be true
            expect(subject.granted? :owner, user: "sally", group: "admins").to be true
            expect(subject.granted? :owner, user: "sally", group: "managers").to be true
            expect(subject.granted? :owner, user: "sally", group: ["admins", "managers"]).to be true
            expect(subject.granted? :owner, user: "bob").to be false
            expect(subject.granted? :owner, user: ["sally", "bob"]).to be false
            expect(subject.granted? :owner, user: "bob", group: ["admins", "managers"]).to be false
            expect(subject.granted? :owner, user: "bob", group: "admins").to be false
            expect(subject.granted? :owner, user: "bob", group: "managers").to be false
            expect(subject.granted? :owner, user: "sally", group: "bozos").to be false
            expect(subject.granted? :owner, user: "sally", group: ["admins", "bozos"]).to be false
          end          
        end
        context "with :any=>true option" do
          it "should return true if any of the principals have been granted the role" do
            expect(subject.granted? :owner, user: "bob", any: true).to be false
            expect(subject.granted? :owner, group: "bozos", any: true).to be false
            expect(subject.granted? :owner, group: ["admins", "bozos"], any: true).to be true
            expect(subject.granted? :owner, user: ["sally", "bob"], any: true).to be true
            expect(subject.granted? :owner, user: "bob", group: ["admins", "managers"], any: true).to be true
            expect(subject.granted? :owner, user: "bob", group: "admins", any: true).to be true
            expect(subject.granted? :owner, user: "bob", group: "managers", any: true).to be true
            expect(subject.granted? :owner, user: "sally", group: "bozos", any: true).to be true
            expect(subject.granted? :owner, user: "bob", group: "bozos", any: true).to be false
            expect(subject.granted? :owner, user: "sally", group: ["admins", "bozos"], any: true).to be true
          end
        end
        context "no :user or :group option" do
          it "should raise an exception" do
            expect { subject.granted? :owner }.to raise_error
          end
        end
      end

      describe "#revoke" do
        context "with :user option" do
          before { subject.grant :owner, user: ["bob", "sally"] }
          it "should remove users from the role" do
            subject.revoke :owner, user: "sally"
            expect(subject.owner.map(&:to_s)).to eq ["bob"]
          end
        end
        context "with :group option" do
          before { subject.grant :owner, group: ["admins", "managers"] }
          it "should remove groups from the role" do
            subject.revoke :owner, group: "managers"
            expect(subject.owner.map(&:to_s)).to eq ["admins"]
          end
        end
        context "no :user or :group option" do
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
