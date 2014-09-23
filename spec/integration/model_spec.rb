require 'spec_helper'

RSpec.describe "model integration", type: :feature do
  before(:all) do
    class RoleModel < ActiveFedora::Base
      include Hydra::Roles
    end
  end
  after(:all) do
    Object.send(:remove_const, :RoleModel)
  end
  let(:obj) { RoleModel.new }
  it "should have a 'roles' datastream" do
    expect(obj.datastreams).to include "roles"
  end
end
