require "rails_helper"

RSpec.describe LicenceFinderController, type: :controller do
  before :each do
    @question1 = "What is your activity or business?"
    @question2 = "What would you like to do?"
    @question3 = "Where will you be located?"
  end

  describe "GET 'sectors'" do
    it "returns no sectors if no query is provided" do
      @s1 = FactoryBot.create(:sector, name: "Alpha")
      @s2 = FactoryBot.create(:sector, name: "Charlie")
      @s3 = FactoryBot.create(:sector, name: "Bravo")

      get :sectors
      expect(response).to be_successful
      expect(assigns[:sectors]).to eq([])
    end

    it "returns all sectors returned from the search" do
      @s1 = FactoryBot.create(:sector, name: "Alpha")
      @s2 = FactoryBot.create(:sector, name: "Charlie")
      @s3 = FactoryBot.create(:sector, name: "Bravo")

      expect($search).to receive(:search).with("test query").and_return([@s1, @s2, @s3])

      get :sectors, params: { q: "test query" }
      expect(response).to be_successful
      expect(assigns[:sectors].to_a).to eq([@s1, @s2, @s3])
    end

    it "sets up the questions correctly" do
      get :sectors
      expect(assigns[:current_question_number]).to eq(1)
      expect(assigns[:completed_questions]).to eq([])
      expect(assigns[:current_question]).to eq(@question1)
      expect(assigns[:upcoming_questions]).to eq([@question2, @question3])
    end

    it "extracts selected sectors ordered alphabetically by name" do
      @s2 = FactoryBot.create(:sector, public_id: 3456, name: "Charlie")
      @s3 = FactoryBot.create(:sector, public_id: 2345, name: "Bravo")

      get :sectors, params: { sectors: "3456_2345_4567" }
      expect(response).to be_successful
      expect(assigns[:picked_sectors]).to eq([@s3, @s2])
    end

    it "returns slimmer headers" do
      expect($search).to receive(:search).with("test query").and_return([])

      get :sectors, params: { q: "test query" }

      expect(response.headers["X-Slimmer-Result-Count"]).to eq("0")
    end

    it "does not return result count if no query was provided" do
      get :sectors

      expect(response.headers["X-Slimmer-Result-Count"]).to be_nil
    end

    it "returns slimmer result count when available" do
      @s1 = FactoryBot.create(:sector, name: "Alpha")
      @s2 = FactoryBot.create(:sector, name: "Charlie")
      @s3 = FactoryBot.create(:sector, name: "Bravo")

      expect($search).to receive(:search).with("test query").and_return([@s1, @s2, @s3])

      get :sectors, params: { q: "test query" }
      expect(response.headers["X-Slimmer-Result-Count"]).to eq("3")
    end
  end

  describe "GET 'activities'" do
    context "with some sectors specified" do
      before :each do
        allow(Sector).to receive(:find_by_public_ids).and_return(:some_sectors)
        allow(Activity).to receive(:find_by_sectors).and_return(Activity)
        allow(Activity).to receive(:ascending)
      end

      def do_get
        get :activities, params: { sectors: "1234_2345_3456" }
      end
      it "and_return http success" do
        do_get
        expect(response).to be_successful
      end

      it "fetches the given sectors and assigns them to @sectors" do
        expect(Sector).to receive(:find_by_public_ids).with([1234, 2345, 3456]).and_return(:some_sectors)
        do_get
        expect(assigns[:sectors]).to eq(:some_sectors)
      end

      it "fetches the activities pertaining to the given sectors ordered by name and assigns them to @activities" do
        scope = double
        expect(scope).to receive(:ascending).with(:name).and_return(:some_activities)
        expect(Activity).to receive(:find_by_sectors).with(:some_sectors).and_return(scope)
        do_get
        expect(assigns[:activities]).to eq(:some_activities)
      end

      it "sets up the questions correctly" do
        do_get
        expect(assigns[:current_question_number]).to eq(2)
        expect(assigns[:completed_questions]).to eq([[@question1, :some_sectors, "sectors"]])
        expect(assigns[:current_question]).to eq(@question2)
        expect(assigns[:upcoming_questions]).to eq([@question3])
      end

      it "extracts the union of selected activities ordered alphabetically by name" do
        a1 = FactoryBot.create(:activity, public_id: 1234, name: "Alpha")
        a2 = FactoryBot.create(:activity, public_id: 2345, name: "Charlie")
        a3 = FactoryBot.create(:activity, public_id: 3456, name: "Bravo")
        scope1 = double
        expect(scope1).to receive(:ascending).with(:name).and_return(:some_activities)
        expect(Activity).to receive(:find_by_sectors).with(:some_sectors).and_return(scope1)

        get :activities, params: { sectors: "1234_2345_3456", activities: "1234_2345_3456" }

        expect(assigns[:picked_activities]).to eq([a1, a3, a2])
      end
    end

    context "when content store returns forbidden response" do
      it "returns a 403 status code" do
        stub_request(:get, "#{Plek.find('content-store')}/content/licence-finder")
          .to_return(status: 403, headers: {})

        get :activities, params: { sectors: "1234_2345_3456" }
        expect(response).to be_forbidden
      end
    end

    context "with no valid sectors selected" do
      it "returns a 404 status code" do
        get :activities
        expect(response).to be_not_found
      end
    end
  end

  describe "GET 'business_location'" do
    context "with sectors and activities specified" do
      before :each do
        allow(Sector).to receive(:find_by_public_ids).and_return(:some_sectors)
        allow(Activity).to receive(:find_by_public_ids).and_return(:some_activities)
      end

      def do_get
        get :business_location, params: { sectors: "123_321", activities: "234_432" }
      end

      it "and_return http success" do
        do_get
        expect(response).to be_successful
      end

      it "fetches the given sectors and assigns them to @sectors" do
        expect(Sector).to receive(:find_by_public_ids).with([123, 321]).and_return(:some_sectors)
        do_get
        expect(assigns[:sectors]).to eq(:some_sectors)
      end

      it "fetches the given activities and assigns them to @activities" do
        expect(Activity).to receive(:find_by_public_ids).with([234, 432]).and_return(:some_activities)
        do_get
        expect(assigns[:activities]).to eq(:some_activities)
      end

      it "sets up the questions correctly" do
        do_get
        expect(assigns[:current_question_number]).to eq(3)
        expect(assigns[:completed_questions]).to eq([
          [@question1, :some_sectors, "sectors"],
          [@question2, :some_activities, "activities"],
        ])
        expect(assigns[:current_question]).to eq(@question3)
        expect(assigns[:upcoming_questions]).to eq([])
      end
    end

    context "with no valid businesses selected, but valid activities" do
      it "returns a 404 status code" do
        get :business_location, params: { activities: "234_432" }
        expect(response).to be_not_found
      end
    end
  end

  describe "POST 'business_location_submit'" do
    context "with valid sectors and activities" do
      context "with a valid location" do
        it "passes through all parameters and redirects to the licences action" do
          post :business_location_submit, params: { sectors: "123_321", activities: "234_432", location: "england" }
          expect(response).to redirect_to(licences_path(sectors: "123_321", activities: "234_432", location: "england"))
        end
      end
      context "with no location" do
        it "passes through sectors and activities and redirects to business_location" do
          post :business_location_submit, params: { sectors: "123_321", activities: "234_432" }
          expect(response).to redirect_to(business_location_path(sectors: "123_321", activities: "234_432"))
        end
      end
      context "with an invalid location" do
        it "passes through sectors and activities and redirect to business_location" do
          post :business_location_submit, params: { sectors: "123_321", activities: "234_432", location: "invalid" }
          expect(response).to redirect_to(business_location_path(sectors: "123_321", activities: "234_432"))
        end
      end
    end

    context "with valid sectors and invalid activities" do
      it "shows an error page" do
        post :business_location_submit, params: { sectors: "123_321", activities: "", location: "anything" }
        expect(response).to be_not_found
      end
    end

    context "with no valid sectors" do
      it "shows an error page" do
        post :business_location_submit, params: { sectors: "", activities: "", location: "anything" }
        expect(response).to be_not_found
      end
    end
  end

  describe "GET 'licences'" do
    context "with sectors, activities and location specified" do
      before :each do
        allow(Sector).to receive(:find_by_public_ids).and_return(:some_sectors)
        allow(Activity).to receive(:find_by_public_ids).and_return(:some_activities)
        allow(Licence).to receive(:find_by_sectors_activities_and_location).and_return(:some_licences)
        allow(LicenceFacade).to receive(:create_for_licences).and_return(:some_licence_facades)
      end
      def do_get
        get :licences, params: { sectors: "123_321", activities: "234_432", location: "northern_ireland" }
      end

      it "fetches the appropriate licences, wraps them in a facade and assigns them to @licences" do
        expect(Sector).to receive(:find_by_public_ids).with([123, 321]).and_return(:some_sectors)
        expect(Activity).to receive(:find_by_public_ids).with([234, 432]).and_return(:some_activities)
        expect(Licence).to receive(:find_by_sectors_activities_and_location).with(:some_sectors, :some_activities, "northern_ireland").and_return(:some_licences)
        expect(LicenceFacade).to receive(:create_for_licences).with(:some_licences).and_return(:some_licence_facades)
        do_get
        expect(assigns[:sectors]).to eq(:some_sectors)
        expect(assigns[:activities]).to eq(:some_activities)
        expect(assigns[:location]).to eq("northern_ireland")
        expect(assigns[:licences]).to eq(:some_licence_facades)
      end

      it "sets up the questions correctly" do
        do_get
        expect(assigns[:completed_questions]).to eq([
          [@question1, :some_sectors, "sectors"],
          [@question2, :some_activities, "activities"],
          [@question3, ["Northern Ireland"], "business_location"],
        ])
      end
    end

    context "with valid sectors and invalid activities" do
      it "shows an error page" do
        get :licences, params: { sectors: "123_321", activities: "", location: "anything" }
        expect(response).to be_not_found
      end
    end

    context "with no valid sectors" do
      it "shows an error page" do
        get :licences, params: { sectors: "", activities: "123_321", location: "england" }
        expect(response).to be_not_found
      end
    end
  end

  describe "GET 'browse sectors'" do
    context "With nested sectors" do
      before :each do
        @s1 = FactoryBot.create(:sector, layer: 1, name: "First top level")
        @s2 = FactoryBot.create(:sector, layer: 2, name: "First child", parents: [@s1])
        @s3 = FactoryBot.create(:sector, layer: 3, name: "First grand child", parents: [@s2])
        @s4 = FactoryBot.create(:sector, layer: 2, name: "Second child", parents: [@s1])
        @s5 = FactoryBot.create(:sector, layer: 3, name: "Second grand child", parents: [@s4])
        @s6 = FactoryBot.create(:sector, layer: 1, name: "Second top level")
      end

      it "shows top level sectors" do
        get :browse_sector_index
        expect(assigns[:sectors]).to eq([@s1, @s6])
        expect(assigns[:child_sectors]).to eq([])
        expect(assigns[:grandchild_sectors]).to eq([])
      end

      it "shows children of top level sectors" do
        get :browse_sector, params: { sector: @s1.public_id }
        expect(assigns[:sectors]).to eq([@s1, @s6])
        expect(assigns[:child_sectors]).to eq([@s2, @s4])
        expect(assigns[:grandchild_sectors]).to eq([])
      end

      it "shows grandchildren of top level sectors" do
        get :browse_sector_child, params: { sector_parent: @s1.public_id, sector: @s2.public_id }
        expect(assigns[:sectors]).to eq([@s1, @s6])
        expect(assigns[:child_sectors]).to eq([@s2, @s4])
        expect(assigns[:grandchild_sectors]).to eq([@s3])
      end
    end
  end
end
