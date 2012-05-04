require 'spec_helper'

describe Activity do
  it "should use the correct field types on the model" do
    Activity.safely.create!(
      :public_id => 42,
      :name => "Some Activity"
    )
    activity = Activity.first
    activity.public_id.should == 42
    activity.name.should == "Some Activity"
  end

  describe "validations" do
    before :each do
      @activity = FactoryGirl.build(:activity)
    end

    it "should have a database level uniqueness constraint on public_id" do
      FactoryGirl.create(:activity, :public_id => 42)
      @activity.public_id = 42
      lambda do
        @activity.safely.save
      end.should raise_error(Mongo::OperationFailure)
    end

    it "should require a name" do
      @activity.name = ''
      @activity.should_not be_valid
    end
  end
end
