require 'spec_helper'

describe Sector do
  it "should use the correct field types on the model" do
    Sector.safely.create!(
      :public_id => 42,
      :correlation_id => 24,
      :name => "Some Sector"
    )
    sector = Sector.first
    sector.public_id.should == 42
    sector.correlation_id.should == 24
    sector.name.should == "Some Sector"
  end

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

    it "should have a database level uniqueness constraint on correlation_id" do
      FactoryGirl.create(:sector, :correlation_id => 42)
      @sector.correlation_id = 42
      lambda do
        @sector.safely.save
      end.should raise_error(Mongo::OperationFailure)
    end

    it "should require a name" do
      @sector.name = ''
      @sector.should_not be_valid
    end
  end

  describe "associations" do
    it "has many activities" do
      a1 = FactoryGirl.create(:activity)
      a2 = FactoryGirl.create(:activity)

      s = FactoryGirl.build(:sector)
      s.activities << a1
      s.activities << a2
      s.save!

      s.reload
      s.activities.should == [a1, a2]
    end
  end

  describe "retrieval" do
    describe "#find_by_public_id" do
      before :each do
        @sector = FactoryGirl.create(:sector)
      end

      it "should be able to retrieve by public_id" do
        found_sector = Sector.find_by_public_id(@sector.public_id)
        found_sector.should == @sector
      end

      it "should fail to retrieve a non-existent public_id" do
        found_sector = Sector.find_by_public_id(@sector.public_id + 1)
        found_sector.should == nil
      end
    end

    describe "#find_by_public_ids" do
      before :each do
        @s1 = FactoryGirl.create(:sector, :public_id => 12)
        @s2 = FactoryGirl.create(:sector, :public_id => 13)
        @s3 = FactoryGirl.create(:sector, :public_id => 14)
      end

      it "should return the sectors for the given id's" do
        sectors = Sector.find_by_public_ids([12, 14])
        sectors.to_a.should =~ [@s1, @s3]
      end

      it "should skip any non-existent sectors" do
        sectors = Sector.find_by_public_ids([12, 34, 13])
        sectors.to_a.should =~ [@s1, @s2]
      end
    end

    describe "#find_by_correlation_id" do
      before :each do
        @sector = FactoryGirl.create(:sector)
      end

      it "should be able to retrieve by correlation_id" do
        found_sector = Sector.find_by_correlation_id(@sector.correlation_id)
        found_sector.should == @sector
      end
    end
  end

  specify "to_s returns the name" do
    s = FactoryGirl.build(:sector, :name => "Foo Sector")
    s.to_s.should == "Foo Sector"
  end

  describe "auto incrementing public_id" do

    it "should set the public_id to the next free public_id when saved" do
      sector = FactoryGirl.build(:sector)
      sector.public_id.should == nil
      sector.save!
      sector.public_id.should == 1

      sector = FactoryGirl.build(:sector)
      sector.public_id.should == nil
      sector.save!
      sector.public_id.should == 2
    end
  end

  describe "other layers" do
    it "should be able to find all layer 1 sectors" do
      FactoryGirl.create(:sector, layer: 1)
      FactoryGirl.create(:sector, layer: 2)
      FactoryGirl.create(:sector, layer: 3)
      Sector.find_layer1_sectors().length.should == 1
    end

    it "should be able to find all layer 3 sectors" do
      FactoryGirl.create(:sector, layer: 1)
      FactoryGirl.create(:sector, layer: 2)
      FactoryGirl.create(:sector, layer: 3)
      Sector.find_layer3_sectors().length.should == 1
    end

    it "should be able to find child sectors" do
      s1 = FactoryGirl.create(:sector, layer: 1)
      s2 = FactoryGirl.create(:sector, layer: 2, parents: [s1])
      s3 = FactoryGirl.create(:sector, layer: 3, parents: [s2])
      s4 = FactoryGirl.create(:sector, layer: 2, parents: [s1])
      FactoryGirl.create(:sector, layer: 2)

      s1.children.to_a.should =~ [s2, s4]
      s2.children.to_a.should == [s3]
      s3.children.to_a.should == []
    end

    it "should be able find parent sectors" do
      s1 = FactoryGirl.create(:sector, layer: 1)
      s2 = FactoryGirl.create(:sector, layer: 2, parents: [s1])
      s3 = FactoryGirl.create(:sector, layer: 3, parents: [s1, s2])
      s4 = FactoryGirl.create(:sector, layer: 2, parents: [s1])
      FactoryGirl.create(:sector, layer: 2)

      s1.parents.to_a.should == []
      s2.parents.to_a.should == [s1]
      s3.parents.to_a.should =~ [s1, s2]
    end
  end
end
