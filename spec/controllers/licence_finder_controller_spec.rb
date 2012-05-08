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
end
