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
      expect do
        @licence_link.with(safe: true).save
      end.to raise_error(Moped::Errors::OperationFailure)
    end
    it "should require a Sector" do
      @licence_link.sector_id = nil
      expect(@licence_link).not_to be_valid
    end
    it "should require an Activity" do
      @licence_link.activity_id = nil
      expect(@licence_link).not_to be_valid
    end
    it "should require a Licence" do
      @licence_link.licence_id = nil
      expect(@licence_link).not_to be_valid
    end
  end

  describe "find_by_sectors_and_activities" do
    before :each do
      @s1 = FactoryGirl.create(:sector, name: "Sector One")
      @s2 = FactoryGirl.create(:sector, name: "Sector Two")

      @a1 = FactoryGirl.create(:activity, name: "Activity One")
      @a2 = FactoryGirl.create(:activity, name: "Activity Two")

      @ll1 = FactoryGirl.create(:licence_link, sector: @s1, activity: @a1)
      @ll2 = FactoryGirl.create(:licence_link, sector: @s1, activity: @a2)
      @ll3 = FactoryGirl.create(:licence_link, sector: @s2, activity: @a2)
    end

    it "should find all licence links that match the provided sectors and activities" do
      found_licence_links = LicenceLink.find_by_sectors_and_activities([@s1, @s2], [@a1, @a2])
      expect(found_licence_links.to_a).to match_array([@ll1, @ll2, @ll3])
    end

    it "should not find the licence link if the sector is not provided" do
      found_licence_links = LicenceLink.find_by_sectors_and_activities([@s1], [@a1, @a2])
      expect(found_licence_links.to_a).to match_array([@ll1, @ll2])
    end

    it "should not find the licence link if the activity is not provided" do
      found_licence_links = LicenceLink.find_by_sectors_and_activities([@s1, @s2], [@a1])
      expect(found_licence_links.to_a).to match_array([@ll1])
    end

    it "should fail if an invalid object is provided as a sector" do
      expect do
        LicenceLink.find_by_sectors_and_activities([@s1, nil], [@a1])
      end.to raise_error(RuntimeError)
    end

    it "should fail if an invalid object is provided as an activity" do
      expect do
        LicenceLink.find_by_sectors_and_activities([@s1], [@a1, nil])
      end.to raise_error(RuntimeError)
    end
  end
end
