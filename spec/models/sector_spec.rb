require 'spec_helper'

describe Sector do

  describe "validations" do
    before :each do
      @sector = FactoryGirl.build(:sector)
    end

    it "should have a database level uniqueness constraint on public_id" do
      FactoryGirl.create(:sector, :public_id => 42)
      @sector.public_id = 42
      lambda do
        @sector.safely.save
      end.should raise_error(Mongo::OperationFailure)
    end
  end
end
