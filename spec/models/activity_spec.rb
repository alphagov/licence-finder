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

  describe "find_by_public_id" do
    before :each do
      @activity = FactoryGirl.create(:activity)
    end

    it "should be able to retrieve by public_id" do
      found_activity = Activity.find_by_public_id(@activity.public_id)
      found_activity.should == @activity
    end

    it "should fail to retrieve a non-existent public_id" do
      found_activity = Activity.find_by_public_id(@activity.public_id + 1)
      found_activity.should == nil
    end
  end
end
