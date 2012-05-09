require 'spec_helper'

describe LicenceLink do
  describe "validations" do
    before :each do
      @licence_link = FactoryGirl.build(:licence_link)
    end
    it "should have a database uniqueness constraint on sector, activity and licence" do
      FactoryGirl.create(:licence_link,
                         sector: @licence_link.sector,
                         activity: @licence_link.activity,
                         licence: @licence_link.licence
      )
      lambda do
        @licence_link.safely.save
      end.should raise_error(Mongo::OperationFailure)
    end
    it "should require a Sector" do
      @licence_link.sector_id = nil
      @licence_link.should_not be_valid
    end
    it "should require an Activity" do
      @licence_link.activity_id = nil
      @licence_link.should_not be_valid
    end
    it "should require a Licence" do
      @licence_link.licence_id = nil
      @licence_link.should_not be_valid
    end
  end
end
