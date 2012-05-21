require 'spec_helper'

describe Licence do
  it "should use the correct field types on the model" do
    Licence.safely.create!(
      :public_id => 42,
      :correlation_id => 24,
      :name => "Some Licence",
      :regulation_area => "Some Regulation Area"
    )
    licence = Licence.first
    licence.public_id.should == 42
    licence.correlation_id.should == 24
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

    it "should have a database level uniqueness constraint on correlation_id" do
      FactoryGirl.create(:licence, :correlation_id => 42)
      @licence.correlation_id = 42
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

  describe "find_by_public_id" do
    before :each do
      @licence = FactoryGirl.create(:licence)
    end

    it "should be able to retrieve by public_id" do
      found_licence = Licence.find_by_public_id(@licence.public_id)
      found_licence.should == @licence
    end

    it "should fail to retrieve a non-existent public_id" do
      found_licence = Licence.find_by_public_id(@licence.public_id + 1)
      found_licence.should == nil
    end
  end

  describe "find_by_correlation_id" do
    before :each do
      @licence = FactoryGirl.create(:licence)
    end

    it "should be able to retrieve by correlation_id" do
      found_licence = Licence.find_by_correlation_id(@licence.correlation_id)
      found_licence.should == @licence
    end

    it "should fail to retrieve a non-existent correlation_id" do
      found_licence = Licence.find_by_correlation_id(@licence.correlation_id + 1)
      found_licence.should == nil
    end
  end

  describe "find_by_sectors_activities_and_location" do
    before :each do
      @s1 = FactoryGirl.create(:sector, name: "Sector One")
      @s2 = FactoryGirl.create(:sector, name: "Sector Two")

      @a1 = FactoryGirl.create(:activity, name: "Activity One")
      @a2 = FactoryGirl.create(:activity, name: "Activity Two")

      @l1 = FactoryGirl.create(:licence, name: "Licence One")
      @l2 = FactoryGirl.create(:licence, name: "Licence Two", da_scotland: true, da_wales: true, da_northern_ireland: true)
      @l3 = FactoryGirl.create(:licence, name: "Licence Three", da_scotland: true)

      @ll1 = FactoryGirl.create(:licence_link, sector: @s1, activity: @a1, licence: @l1)
      @ll2 = FactoryGirl.create(:licence_link, sector: @s1, activity: @a2, licence: @l2)
      @ll3 = FactoryGirl.create(:licence_link, sector: @s2, activity: @a2, licence: @l3)
    end

    it "should find all licences that match sectors, activities and location" do
      found_licences = Licence.find_by_sectors_activities_and_location([@s1, @s2], [@a1, @a2], :england)
      found_licences.to_a.should =~ [@l1, @l2, @l3]
    end

    it "should not match licences if the location does not match" do
      found_licences = Licence.find_by_sectors_activities_and_location([@s1, @s2], [@a1, @a2], :scotland)
      found_licences.to_a.should =~ [@l2, @l3]
    end

    it "should not match if the sector matches but the activity does not" do
      found_licences = Licence.find_by_sectors_activities_and_location([@s1, @s2], [@a1], :england)
      found_licences.to_a.should =~ [@l1]
    end

    it "should not match if the activity matches but the sector does not" do
      found_licences = Licence.find_by_sectors_activities_and_location([@s1], [@a1, @a2], :england)
      found_licences.to_a.should =~ [@l1, @l2]
    end
  end

  describe "auto incrementing public_id" do
    it "should set the public_id to the next free public_id on save" do
      licence = FactoryGirl.build(:licence)
      licence.public_id.should == nil
      licence.save!
      licence.public_id.should == 1

      licence = FactoryGirl.build(:licence)
      licence.public_id.should == nil
      licence.save!
      licence.public_id.should == 2
    end

  end
end
