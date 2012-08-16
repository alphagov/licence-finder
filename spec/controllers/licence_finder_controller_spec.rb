require 'spec_helper'

describe LicenceFinderController do
  before :each do
    @question1 = 'What is your activity or business?'
    @question2 = 'What would you like to do?'
    @question3 = 'Where will you be located?'
  end

  describe "GET 'start'" do
    it "returns http success" do
      get 'start'
      response.should be_success
    end

    describe "setting up popular licences" do
      before :each do
        LicenceFinderController::POPULAR_LICENCE_IDS.each_with_index do |gds_id, i|
          l = FactoryGirl.create(:licence, :gds_id => gds_id)
          instance_variable_set("@l#{i}", l) # @l1 = l
        end
      end

      it "should assign facades for the published licences to @popular_licences" do
        lf1 = stub("lf1", :published? => true)
        lf2 = stub("lf2", :published? => false)
        lf3 = stub("lf3", :published? => false)
        lf4 = stub("lf4", :published? => true)
        LicenceFacade.should_receive(:create_for_licences).with([@l0, @l1, @l2, @l3, @l4, @l5, @l6]).
          and_return([lf1, lf2, lf3, lf4])

        get :start

        assigns[:popular_licences].should == [lf1, lf4]
      end

      it "should only assign the first 3 to @popular_licences" do
        lf1 = stub("lf1", :published? => true)
        lf2 = stub("lf2", :published? => false)
        lf3 = stub("lf3", :published? => true)
        lf4 = stub("lf4", :published? => true)
        lf5 = stub("lf5", :published? => true)
        LicenceFacade.stub(:create_for_licences).
          and_return([lf1, lf2, lf3, lf4, lf5])

        get :start

        assigns[:popular_licences].should == [lf1, lf3, lf4]
      end

      it "should cope with licences missing from the local database" do
        @l1.destroy
        @l2.destroy
        lf1 = stub("lf1", :published? => true)
        LicenceFacade.should_receive(:create_for_licences).with([@l0, @l3, @l4, @l5, @l6]).
          and_return([lf1])

        get :start

        assigns[:popular_licences].should == [lf1]
      end
    end
  end

  describe "GET 'sectors'" do

    it "should return no sectors if no query is provided" do
      @s1 = FactoryGirl.create(:sector, :name => "Alpha")
      @s2 = FactoryGirl.create(:sector, :name => "Charlie")
      @s3 = FactoryGirl.create(:sector, :name => "Bravo")

      get :sectors
      response.should be_success
      assigns[:sectors].should == []
    end

    it "should return all sectors returned from the search" do
      @s1 = FactoryGirl.create(:sector, :name => "Alpha")
      @s2 = FactoryGirl.create(:sector, :name => "Charlie")
      @s3 = FactoryGirl.create(:sector, :name => "Bravo")

      $search.should_receive(:search).with("test query").and_return([@s1, @s2, @s3])

      get :sectors, q: "test query"
      response.should be_success
      assigns[:sectors].to_a.should == [@s1, @s2, @s3]
    end

    it "sets up the questions correctly" do
      get :sectors
      assigns[:current_question_number].should == 1
      assigns[:completed_questions].should == []
      assigns[:current_question].should == @question1
      assigns[:upcoming_questions].should == [@question2, @question3]
    end

    it "extracts selected sectors ordered alphabetically by name" do
      @s2 = FactoryGirl.create(:sector, :public_id => 3456, :name => "Charlie")
      @s3 = FactoryGirl.create(:sector, :public_id => 2345, :name => "Bravo")

      get :sectors, :sectors => '3456_2345_4567'
      response.should be_success
      assigns[:picked_sectors].should == [@s3, @s2]
    end

    it "should return slimmer headers" do
      $search.should_receive(:search).with("test query").and_return([])
      get :sectors, q: "test query"
      response.headers["X-Slimmer-Need-ID"].should == "B90"
      response.headers["X-Slimmer-Format"].should == "licence-finder"
      response.headers["X-Slimmer-Proposition"].should == "business"
      response.headers["X-Slimmer-Result-Count"].should == "0"
    end

    it "should not return result count if no query was provided" do
      get :sectors
      response.headers["X-Slimmer-Result-Count"].should be_nil
    end

    it "should return slimmer result count when available" do
      @s1 = FactoryGirl.create(:sector, :name => "Alpha")
      @s2 = FactoryGirl.create(:sector, :name => "Charlie")
      @s3 = FactoryGirl.create(:sector, :name => "Bravo")

      $search.should_receive(:search).with("test query").and_return([@s1, @s2, @s3])

      get :sectors, q: "test query"
      response.should be_success
      response.headers["X-Slimmer-Result-Count"].should == "3"
    end
  end

  describe "GET 'activities'" do
    context "with some sectors specified" do
      before :each do
        Sector.stub(:find_by_public_ids).and_return(:some_sectors)
        Activity.stub(:find_by_sectors).and_return(Activity)
        Activity.stub(:ascending)
      end

      def do_get
        get :activities, :sectors => "1234_2345_3456"
      end
      it "and_return http success" do
        do_get
        response.should be_success
      end

      it "fetches the given sectors and assigns them to @sectors" do
        Sector.should_receive(:find_by_public_ids).with([1234,2345,3456]).and_return(:some_sectors)
        do_get
        assigns[:sectors].should == :some_sectors
      end

      it "fetches the activities pertaining to the given sectors ordered by name and assigns them to @activities" do
        scope = stub()
        scope.should_receive(:ascending).with(:name).and_return(:some_activities)
        Activity.should_receive(:find_by_sectors).with(:some_sectors).and_return(scope)
        do_get
        assigns[:activities].should == :some_activities
      end

      it "sets up the questions correctly" do
        do_get
        assigns[:current_question_number].should == 2
        assigns[:completed_questions].should == [ [@question1, :some_sectors, 'sectors'] ]
        assigns[:current_question].should == @question2
        assigns[:upcoming_questions].should == [@question3]
      end

      it "extracts the union of selected activities ordered alphabetically by name" do
        a1 = FactoryGirl.create(:activity, :public_id => 1234, :name => "Alpha")
        a2 = FactoryGirl.create(:activity, :public_id => 2345, :name => "Charlie")
        a3 = FactoryGirl.create(:activity, :public_id => 3456, :name => "Bravo")
        scope1 = stub()
        scope1.should_receive(:ascending).with(:name).and_return(:some_activities)
        Activity.should_receive(:find_by_sectors).with(:some_sectors).and_return(scope1)

        get :activities, :sectors => "1234_2345_3456", :activities => "1234_2345_3456"

        assigns[:picked_activities].should == [a1, a3, a2]
      end

      it "should core return slimmer headers but no result count" do
        do_get
        response.headers["X-Slimmer-Need-ID"].should == "B90"
        response.headers["X-Slimmer-Format"].should == "licence-finder"
        response.headers["X-Slimmer-Proposition"].should == "business"
        response.headers["X-Slimmer-Result-Count"].should == nil
      end
    end

    context "with no valid sectors selected" do
      it "should return a 404 status code" do
        get :activities
        response.should be_not_found
      end
    end

  end

  describe "GET 'business_location'" do
    context "with sectors and activities specified" do
      before :each do
        Sector.stub(:find_by_public_ids).and_return(:some_sectors)
        Activity.stub(:find_by_public_ids).and_return(:some_activities)
      end

      def do_get
        get :business_location, :sectors => '123_321', :activities => '234_432'
      end

      it "and_return http success" do
        do_get
        response.should be_success
      end

      it "fetches the given sectors and assigns them to @sectors" do
        Sector.should_receive(:find_by_public_ids).with([123,321]).and_return(:some_sectors)
        do_get
        assigns[:sectors].should == :some_sectors
      end

      it "fetches the given activities and assigns them to @activities" do
        Activity.should_receive(:find_by_public_ids).with([234,432]).and_return(:some_activities)
        do_get
        assigns[:activities].should == :some_activities
      end

      it "sets up the questions correctly" do
        do_get
        assigns[:current_question_number].should == 3
        assigns[:completed_questions].should == [
            [@question1, :some_sectors, 'sectors'],
            [@question2, :some_activities, 'activities']
        ]
        assigns[:current_question].should == @question3
        assigns[:upcoming_questions].should == []
      end
    end

    context "with no valid businesses selected, but valid activities" do
      it "should return a 404 status code" do
        get :business_location, :activities => '234_432'
        response.should be_not_found
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
      it "should show an error page" do
        post :business_location_submit, :sectors => '123_321', :activities => '', :location => 'anything'
        response.should be_not_found
      end
    end

    context "with no valid sectors" do
      it "should show an error page" do
        post :business_location_submit, :sectors => '', :activities => '', :location => 'anything'
        response.should be_not_found
      end
    end
  end

  describe "GET 'licences'" do
    context "with sectors, activities and location specified" do
      before :each do
        Sector.stub(:find_by_public_ids).and_return(:some_sectors)
        Activity.stub(:find_by_public_ids).and_return(:some_activities)
        Licence.stub(:find_by_sectors_activities_and_location).and_return(:some_licences)
        LicenceFacade.stub(:create_for_licences).and_return(:some_licence_facades)
      end
      def do_get
        get :licences, :sectors => '123_321', :activities => '234_432', :location => "northern_ireland"
      end

      it "fetches the appropriate licences, wraps them in a facade and assigns them to @licences" do
        Sector.should_receive(:find_by_public_ids).with([123,321]).and_return(:some_sectors)
        Activity.should_receive(:find_by_public_ids).with([234,432]).and_return(:some_activities)
        Licence.should_receive(:find_by_sectors_activities_and_location).with(:some_sectors, :some_activities, "northern_ireland").and_return(:some_licences)
        LicenceFacade.should_receive(:create_for_licences).with(:some_licences).and_return(:some_licence_facades)
        do_get
        assigns[:sectors].should == :some_sectors
        assigns[:activities].should == :some_activities
        assigns[:location].should == "northern_ireland"
        assigns[:licences].should == :some_licence_facades
      end

      it "sets up the questions correctly" do
        do_get
        assigns[:completed_questions].should == [
            [@question1, :some_sectors, 'sectors'],
            [@question2, :some_activities, 'activities'],
            [@question3, ['Northern Ireland'], 'business_location']
        ]
      end
    end

    context "with valid sectors and invalid activities" do
      it "should show an error page" do
        get :licences, :sectors => '123_321', :activities => '', :location => 'anything'
        response.should be_not_found
      end
    end

    context "with no valid sectors" do
      it "should show an error page" do
        get :licences, :sectors => '', :activities => '123_321', :location => 'england'
        response.should be_not_found
      end
    end

  end

  describe "GET 'browse sectors'" do
    context 'With nested sectors' do
      before :each do
        @s1 = FactoryGirl.create(:sector, layer: 1, name: 'First top level')
        @s2 = FactoryGirl.create(:sector, layer: 2, name: 'First child', parents: [@s1])
        @s3 = FactoryGirl.create(:sector, layer: 3, name: 'First grand child', parents: [@s2])
        @s4 = FactoryGirl.create(:sector, layer: 2, name: 'Second child', parents: [@s1])
        @s5 = FactoryGirl.create(:sector, layer: 3, name: 'Second grand child', parents: [@s4])
        @s6 = FactoryGirl.create(:sector, layer: 1, name: 'Second top level')
      end

      it 'Should show top level sectors' do
        get :browse_sector_index
        assigns[:sectors].should == [@s1, @s6]
        assigns[:child_sectors].should == []
        assigns[:grandchild_sectors].should == []
      end

      it 'Should show children of top level sectors' do
        get :browse_sector, :sector => @s1.public_id
        assigns[:sectors].should == [@s1, @s6]
        assigns[:child_sectors].should == [@s2, @s4]
        assigns[:grandchild_sectors].should == []
      end

      it 'Should show grandchildren of top level sectors' do
        get :browse_sector_child, :sector_parent => @s1.public_id, :sector => @s2.public_id
        assigns[:sectors].should == [@s1, @s6]
        assigns[:child_sectors].should == [@s2, @s4]
        assigns[:grandchild_sectors].should == [@s3]
      end
    end
  end
end
