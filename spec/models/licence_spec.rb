require 'rails_helper'

RSpec.describe Licence, type: :model do
  it "should use the correct field types on the model" do
    Licence.create!(
      gds_id: "24-3-1",
      name: "Some Licence",
      regulation_area: "Some Regulation Area"
    )
    licence = Licence.first
    expect(licence.gds_id).to eq("24-3-1")
    expect(licence.name).to eq("Some Licence")
    expect(licence.regulation_area).to eq("Some Regulation Area")
  end

  describe "validations" do
    before :each do
      @licence = FactoryBot.build(:licence)
    end

    it "should have a database level uniqueness constraint on gds_id" do
      FactoryBot.create(:licence, gds_id: "24-3-1")
      @licence.gds_id = "24-3-1"
      expect {
        @licence.save
      }.to raise_error(Mongo::Error::OperationFailure)
    end

    it "should require a name" do
      @licence.name = ''
      expect(@licence).not_to be_valid
    end

    it "should require a regulation_area" do
      @licence.regulation_area = ''
      expect(@licence).not_to be_valid
    end
  end

  describe "find_by_gds_id" do
    before :each do
      @licence = FactoryBot.create(:licence)
    end

    it "should be able to retrieve by gds_id" do
      found_licence = Licence.find_by_gds_id(@licence.gds_id)
      expect(found_licence).to eq(@licence)
    end

    it "should fail to retrieve a non-existent gds_id" do
      found_licence = Licence.find_by_gds_id("24-3-2")
      expect(found_licence).to eq(nil)
    end
  end

  describe "find_by_sectors_activities_and_location" do
    before :each do
      @s1 = FactoryBot.create(:sector, name: "Sector One")
      @s2 = FactoryBot.create(:sector, name: "Sector Two")

      @a1 = FactoryBot.create(:activity, name: "Activity One")
      @a2 = FactoryBot.create(:activity, name: "Activity Two")

      @l1 = FactoryBot.create(:licence, name: "Licence One")
      @l2 = FactoryBot.create(:licence, name: "Licence Two", da_scotland: true, da_wales: true, da_northern_ireland: true)
      @l3 = FactoryBot.create(:licence, name: "Licence Three", da_scotland: true)

      @ll1 = FactoryBot.create(:licence_link, sector: @s1, activity: @a1, licence: @l1)
      @ll2 = FactoryBot.create(:licence_link, sector: @s1, activity: @a2, licence: @l2)
      @ll3 = FactoryBot.create(:licence_link, sector: @s2, activity: @a2, licence: @l3)
    end

    it "should find all licences that match sectors, activities and location" do
      found_licences = Licence.find_by_sectors_activities_and_location([@s1, @s2], [@a1, @a2], :england)
      expect(found_licences.to_a).to match_array([@l1, @l2, @l3])
    end

    it "should not match licences if the location does not match" do
      found_licences = Licence.find_by_sectors_activities_and_location([@s1, @s2], [@a1, @a2], :scotland)
      expect(found_licences.to_a).to match_array([@l2, @l3])
    end

    it "should not match if the sector matches but the activity does not" do
      found_licences = Licence.find_by_sectors_activities_and_location([@s1, @s2], [@a1], :england)
      expect(found_licences.to_a).to match_array([@l1])
    end

    it "should not match if the activity matches but the sector does not" do
      found_licences = Licence.find_by_sectors_activities_and_location([@s1], [@a1, @a2], :england)
      expect(found_licences.to_a).to match_array([@l1, @l2])
    end
  end
end
