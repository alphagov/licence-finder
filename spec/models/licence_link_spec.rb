require 'spec_helper'

describe LicenceLink do
  describe "validations" do
    before :each do
      @licence_link = FactoryGirl.build(:licence_link)
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
