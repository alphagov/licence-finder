require "rails_helper"

RSpec.describe Activity, type: :model do
  it "should use the correct field types on the model" do
    Activity.create!(
      public_id: 42,
      correlation_id: 24,
      name: "Some Activity",
    )
    activity = Activity.first
    expect(activity.public_id).to eq(42)
    expect(activity.correlation_id).to eq(24)
    expect(activity.name).to eq("Some Activity")
  end

  describe "validations" do
    before :each do
      @activity = FactoryBot.build(:activity)
    end

    it "should have a database level uniqueness constraint on public_id" do
      FactoryBot.create(:activity, public_id: 42)
      @activity.public_id = 42
      expect {
        @activity.save
      }.to raise_error(Mongo::Error::OperationFailure)
    end

    it "should have a database level uniqueness constraint on correlation_id" do
      FactoryBot.create(:activity, correlation_id: 42)
      @activity.correlation_id = 42
      expect {
        @activity.save
      }.to raise_error(Mongo::Error::OperationFailure)
    end

    it "should require a name" do
      @activity.name = ""
      expect(@activity).not_to be_valid
    end
  end

  describe "associations" do
    it "has many sectors" do
      s1 = FactoryBot.create(:sector)
      s2 = FactoryBot.create(:sector)

      a = FactoryBot.build(:activity)
      a.sectors << s1
      a.sectors << s2
      a.save!

      a.reload
      expect(a.sectors).to eq([s1, s2])
    end
  end

  describe "retreival" do
    describe "find_by_public_id" do
      before :each do
        @activity = FactoryBot.create(:activity)
      end

      it "should be able to retrieve by public_id" do
        found_activity = Activity.find_by_public_id(@activity.public_id)
        expect(found_activity).to eq(@activity)
      end

      it "should fail to retrieve a non-existent public_id" do
        found_activity = Activity.find_by_public_id(@activity.public_id + 1)
        expect(found_activity).to eq(nil)
      end
    end

    describe "find_by_public_ids" do
      before :each do
        @a1 = FactoryBot.create(:activity, public_id: 10)
        @a2 = FactoryBot.create(:activity, public_id: 11)
        @a3 = FactoryBot.create(:activity, public_id: 12)
      end

      it "should return the activities for the given id's" do
        found_activities = Activity.find_by_public_ids([10, 11])
        expect(found_activities.to_a).to match_array([@a1, @a2])
      end

      it "should skip any non-existent activities" do
        found_activities = Activity.find_by_public_ids([10, 12, 13])
        expect(found_activities.to_a).to match_array([@a1, @a3])
      end
    end

    describe "find_by_correlation_id" do
      before :each do
        @activity = FactoryBot.create(:activity)
      end

      it "should be able to retrieve by correlation_id" do
        found_activity = Activity.find_by_correlation_id(@activity.correlation_id)
        expect(found_activity).to eq(@activity)
      end

      it "should fail to retrieve a non-existent correlation_id" do
        found_activity = Activity.find_by_correlation_id(@activity.correlation_id + 1)
        expect(found_activity).to eq(nil)
      end
    end

    describe "find_by_sectors" do
      before :each do
        @s1 = FactoryBot.create(:sector, name: "Fooey Sector")
        @s2 = FactoryBot.create(:sector, name: "Kablooey Sector")
        @s3 = FactoryBot.create(:sector, name: "Gooey Sector")

        @a1 = FactoryBot.create(:activity, name: "Fooey Activity", sectors: [@s1])
        @a2 = FactoryBot.create(:activity, name: "Kablooey Activity", sectors: [@s2])
        @a3 = FactoryBot.create(:activity, name: "Gooey Activity", sectors: [@s3])
        @a4 = FactoryBot.create(:activity, name: "Kabloom", sectors: [@s1, @s2])
        @a5 = FactoryBot.create(:activity, name: "Transmogrifying", sectors: [@s1, @s3])
      end

      it "should return activities relating to the given sectors" do
        expect(Activity.find_by_sectors([@s2, @s3]).to_a).to match_array([@a2, @a3, @a4, @a5])
      end

      it "should only return each activity once" do
        expect(Activity.find_by_sectors([@s1, @s3]).to_a).to match_array([@a1, @a3, @a4, @a5])
      end

      it "returns activities in a way that's chainable with other scopes" do
        expect(Activity.find_by_sectors([@s2, @s3]).ascending(:name)).to eq([@a3, @a2, @a4, @a5])
      end
    end
  end

  specify "to_s returns the name" do
    a = FactoryBot.build(:activity, name: "Foo Activity")
    expect(a.to_s).to eq("Foo Activity")
  end

  describe "auto incrementing public_id" do
    it "should set the public_id to the next free public_id on save" do
      activity = FactoryBot.build(:activity)
      expect(activity.public_id).to eq(nil)
      activity.save!
      expect(activity.public_id).to eq(1)

      activity = FactoryBot.build(:activity)
      expect(activity.public_id).to eq(nil)
      activity.save!
      expect(activity.public_id).to eq(2)
    end

    it "should use a separate sequence for each model" do
      activity = FactoryBot.create(:activity)
      expect(activity.public_id).to eq(1)
      FactoryBot.create(:licence)
      activity = FactoryBot.create(:activity)
      expect(activity.public_id).to eq(2)
    end
  end
end
