require 'spec_helper'

describe Licence do
  it "should use the correct field types on the model" do
    Licence.safely.create!(
      :public_id => 42,
      :name => "Some Licence",
      :regulation_area => "Some Regulation Area"
    )
    licence = Licence.first
    licence.public_id.should == 42
    licence.name.should == "Some Licence"
  end

  describe "validations" do
    before :each do
      @licence = FactoryGirl.build(:licence)
    end

    it "should have a database level uniqueness constraint on public_id" do
      FactoryGirl.create(:licence, :public_id => 42)
      @licence.public_id = 42
      lambda do
        @licence.safely.save
      end.should raise_error(Mongo::OperationFailure)
    end

    it "should require a name" do
      @licence.name = ''
      @licence.should_not be_valid
    end

    it "should require a regulation_area" do
      @licence.regulation_area = ''
      @licence.should_not be_valid
    end
  end
end
