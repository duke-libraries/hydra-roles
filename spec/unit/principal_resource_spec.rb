require 'spec_helper'

module Hydra
  module Roles
    RSpec.describe PrincipalResource do
      subject { described_class.new }
      describe "validation" do
        it "should require the presence of a name" do
          expect(subject).not_to be_valid
          subject.name = "bob"
          expect(subject).to be_valid
        end
        it "should enforce single cardinality on the name" do
          subject.name = "bob"
          expect(subject).to be_valid
          subject.name << "sally"
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
