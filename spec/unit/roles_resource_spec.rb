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
            expect(subject.to_hash[:owner][:user]).to match_array ["bob", "sally"]
          end
        end
        context "with :group option" do
          before { subject.owner << GroupResource.build("admins") }
          it "should add groups to the role that do not already have the role" do
            subject.grant :owner, group: ["admins", "managers"]
            expect(subject.to_hash[:owner][:group]).to match_array ["admins", "managers"]
          end
        end
        context "no :user or :group option" do
          it "should raise an exception" do
            expect { subject.grant :owner }.to raise_error
          end
        end
        context "multiple roles" do
          let(:opts) { { user: ["bob", "sally"], group: "admins" } }
          let(:roles) { [:owner, :administrator] }
          let(:args) { roles.dup << opts }
          it "should grant the roles to all principals" do
            subject.grant *args
            roles.each do |role|
              expect(subject.to_hash[role]).to eq({user: ["bob", "sally"], group: ["admins"]})
            end
          end
        end
      end

      describe "#granted?" do
        before { subject.grant *args }
        let(:roles) { [:owner, :contributor] }
        let(:bad_role) { :administrator }
        let(:user) { "sally" }
        let(:bad_user) { "bob" }
        let(:group) { ["admins", "managers"] }
        let(:bad_group) { "bozos" }
        let(:opts) { {user: user, group: group} }
        let(:bad_opts) { {user: bad_user, group: bad_group} }
        let(:args) { roles.dup << opts }
        let(:bad_args) { [bad_role, bad_opts] }
        context "default behavior" do
          it "should return true if and only if all principals have been granted all roles" do
            expect(subject.granted? *args).to be true
            expect(subject.granted? *bad_args).to be false
            expect(subject.granted?(*roles, user: user)).to be true
            expect(subject.granted?(bad_role, user: user)).to be false
            expect(subject.granted?(*roles, user: bad_user)).to be false
            expect(subject.granted?(*roles, user: [user, bad_user])).to be false
            expect(subject.granted?(*roles, group: group)).to be true
            expect(subject.granted?(bad_role, group: group)).to be false
            expect(subject.granted?(*roles, group: bad_group)).to be false
            expect(subject.granted?(*roles, group: (group.dup << bad_group))).to be false
            roles.each do |role|
              expect(subject.granted?(role, opts)).to be true
              expect(subject.granted?(role, user: user)).to be true
              expect(subject.granted?(role, user: bad_user)).to be false
              expect(subject.granted?(role, user: [user, bad_user])).to be false
              expect(subject.granted?(role, group: group)).to be true
              expect(subject.granted?(role, group: bad_group)).to be false
              expect(subject.granted?(role, group: (group.dup << bad_group))).to be false
            end
          end          
        end
        context "with :any_principal=>true option" do
          it "should return true if any of the principals have been granted (all) the roles" do
            expect(subject.granted?(*roles, user: [user, bad_user], any_principal: true)).to be true
            expect(subject.granted?(*roles, user: bad_user, any_principal: true)).to be false
            expect(subject.granted?(*roles, group: (group.dup << bad_group), any_principal: true)).to be true
          end
        end
        context "with :any_role=>true option" do
          it "should return true if (all) the principals have any of the roles" do
            expect(subject.granted?(*(roles.dup << bad_role), user: user, any_role: true)).to be true
            expect(subject.granted?(*(roles.dup << bad_role), user: bad_user, any_role: true)).to be false
            expect(subject.granted?(*(roles.dup << bad_role), user: [user, bad_user], any_role: true)).to be false
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
