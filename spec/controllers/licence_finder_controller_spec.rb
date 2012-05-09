require 'spec_helper'

describe LicenceFinderController do

  describe "GET 'start'" do
    it "returns http success" do
      get 'start'
      response.should be_success
    end
  end

  describe "GET 'sectors'" do
    it "returns http success" do
      get :sectors
      response.should be_success
    end

    it "assigns all sectors ordered alphabetically by name" do
      @s1 = FactoryGirl.create(:sector, :name => "Alpha")
      @s2 = FactoryGirl.create(:sector, :name => "Charlie")
      @s3 = FactoryGirl.create(:sector, :name => "Bravo")

      get :sectors
      assigns[:sectors].to_a.should == [@s1, @s3, @s2]
    end
  end

  describe "POST 'sectors_submit'" do
    context "with some sectors selected" do
      it "combines the sector_ids into a single param, and redirects to the activities action" do
        post :sectors_submit, :sector_ids => ["1234", "2345", "32456"]
        response.should redirect_to(activities_path(:sectors => "1234,2345,32456"))
      end

      it "should order the sector_ids numerically" do
        post :sectors_submit, :sector_ids => ["1234", "345", "32456"]
        response.should redirect_to(activities_path(:sectors => "345,1234,32456"))
      end

      it "should sanitise any non-numeric entries" do
        post :sectors_submit, :sector_ids => ["1234", "foo", "32456", "", "-1"]
        response.should redirect_to(activities_path(:sectors => "1234,32456"))
      end
    end

    context "with no sectors selected" do
      it "redirects to the sectors action" do
        post :sectors_submit
        response.should redirect_to(sectors_path)
      end

      it "redirects to the sectors action with no numeric sector_ids" do
        post :sectors_submit, :sector_ids => ["foo", "", "-1"]
        response.should redirect_to(sectors_path)
      end

      it "sets an error somehow"

    end
  end

  describe "GET 'activities'" do
    context "with some sectors specified" do
      before :each do
        Sector.stubs(:find_by_public_ids).returns(:some_sectors)
        Activity.stubs(:find_by_sectors).returns(Activity)
        Activity.stubs(:ascending)
      end

      def do_get
        get :activities, :sectors => "1234,2345,3456"
      end

      it "returns http success" do
        do_get
        response.should be_success
      end

      it "fetches the given sectors and assigns them to @sectors" do
        Sector.expects(:find_by_public_ids).with([1234,2345,3456]).returns(:some_sectors)
        do_get
        assigns[:sectors].should == :some_sectors
      end

      it "fetches the activities pertaining to the given sectors ordered by name and assigns them to @activities" do
        scope = stub()
        scope.expects(:ascending).with(:name).returns(:some_activities)
        Activity.expects(:find_by_sectors).with(:some_sectors).returns(scope)
        do_get
        assigns[:activities].should == :some_activities
      end
    end

  end
end
