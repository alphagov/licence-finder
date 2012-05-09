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
        response.should redirect_to(activities_path(:sectors => "1234_2345_32456"))
      end

      it "should order the sector_ids numerically" do
        post :sectors_submit, :sector_ids => ["1234", "345", "32456"]
        response.should redirect_to(activities_path(:sectors => "345_1234_32456"))
      end

      it "should sanitise any non-numeric entries" do
        post :sectors_submit, :sector_ids => ["1234", "foo", "32456", "", "-1"]
        response.should redirect_to(activities_path(:sectors => "1234_32456"))
      end
    end

    context "with no valid sectors selected" do
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
        get :activities, :sectors => "1234_2345_3456"
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

  describe "POST 'activities_submit'" do
    context "with sectors and some activities selected" do
      it "passes through the sectors, combines the activity_ids into a single param, and redirects to the location action" do
        post :activities_submit, :sectors => '123_321', :activity_ids => %w(234 432)
        response.should redirect_to(business_location_path(:sectors => '123_321', :activities => '234_432'))
      end

      it "should order the activity_ids numerically" do
        post :activities_submit, :sectors => '123_321', :activity_ids => %w(432 234)
        response.should redirect_to(business_location_path(:sectors => '123_321', :activities => '234_432'))
      end

      it "should sanitise any non-numeric entries" do
        post :activities_submit, :sectors => '123_321', :activity_ids => %w(234 foo 432 -1)
        response.should redirect_to(business_location_path(:sectors => '123_321', :activities => '234_432'))
      end
    end

    context "with sectors but no valid activities selected" do
      it "redirects to the activities action with the sectors selected" do
        post :activities_submit, :sectors => '123_321'
        response.should redirect_to(activities_path(:sectors => '123_321'))
      end

      it "redirects to the activities action with no numeric activity_ids" do
        post :activities_submit, :sectors => '123_321', :activity_ids => %w(foo -1)
        response.should redirect_to(activities_path(:sectors => '123_321'))
      end
    end

    context "invalid sectors" do
      it "redirects to the sectors action with no sectors" do
        post :activities_submit
        response.should redirect_to(sectors_path)
      end

      it "redirects to the sectors action with no valid sectors"
    end
  end

  describe "GET 'business_location'" do
    context "with sectors and activities specified" do
      before :each do
        Sector.stubs(:find_by_public_ids).returns(:some_sectors)
        Activity.stubs(:find_by_public_ids).returns(:some_activities)
      end

      def do_get
        get :business_location, :sectors => '123_321', :activities => '234_432'
      end

      it "returns http success" do
        do_get
        response.should be_success
      end

      it "fetches the given sectors and assigns them to @sectors" do
        Sector.expects(:find_by_public_ids).with([123,321]).returns(:some_sectors)
        do_get
        assigns[:sectors].should == :some_sectors
      end

      it "fetches the given activities and assigns them to @activities" do
        Activity.expects(:find_by_public_ids).with([234,432]).returns(:some_activities)
        do_get
        assigns[:activities].should == :some_activities
      end
    end
  end

  describe "POST 'business_location_submit'" do
    context "with valid sectors and activities" do
      context "with a valid location" do
        it "should pass through all parameters and redirects to the licences action" do
          post :business_location_submit, :sectors => '123_321', :activities => '234_432', :location => "england"
          response.should redirect_to(licences_path(:sectors => '123_321', :activities => '234_432', :location => "england"))
        end
      end
      context "with no location" do
        it "should pass through sectors and activities and redirect to business_location" do
          post :business_location_submit, :sectors => '123_321', :activities => '234_432'
          response.should redirect_to(business_location_path(:sectors => '123_321', :activities => '234_432'))
        end
      end
      context "with an invalid location" do
        it "should pass through sectors and activities and redirect to business_location" do
          post :business_location_submit, :sectors => '123_321', :activities => '234_432', :location => 'invalid'
          response.should redirect_to(business_location_path(:sectors => '123_321', :activities => '234_432'))
        end
      end
    end

    context "with valid sectors and invalid activities" do
      it "should redirect back to the activities form" do
        post :business_location_submit, :sectors => '123_321', :activities => '', :location => 'anything'
        response.should redirect_to(activities_path(:sectors => '123_321'))
      end
    end

    context "with no valid sectors" do
      it "should redirect back to the sectors form" do
        post :business_location_submit, :sectors => '', :activities => '', :location => 'anything'
        response.should redirect_to(sectors_path)
      end
    end
  end
end
