require "rails_helper"

RSpec.describe LicenceFacade, type: :model do
  include RummagerHelpers

  describe "create_for_licences" do
    before :each do
      @l1 = FactoryBot.create(:licence)
      @l2 = FactoryBot.create(:licence)
    end

    it "should query Rummager for licence details" do
      rummager_has_licences([@l1, @l2], when_searching_for: [@l1, @l2])

      LicenceFacade.create_for_licences([@l1, @l2])
    end

    it "should skip querying Rummager if not given any licences" do
      request = stub_any_search
      LicenceFacade.create_for_licences([])
      expect(request).not_to have_been_made
    end

    it "should construct Facades for each licence maintaining order" do
      rummager_has_licences([@l1, @l2], when_searching_for: [@l1, @l2])

      result = LicenceFacade.create_for_licences([@l1, @l2])
      expect(result.map(&:licence)).to eq([@l1, @l2])
    end

    it "should add the Rummager details to each Facade where details exist" do
      rummager_has_licences([@l2], when_searching_for: [@l1, @l2])

      result = LicenceFacade.create_for_licences([@l1, @l2])
      expect(result[0].licence).to eq(@l1)
      expect(result[0].search_result).to eq(nil)
      expect(result[1].licence).to eq(@l2)
      expect(result[1].search_result).to eq(rummager_licence_hash(@l2.gds_id))
    end

    context "when the Search API errors" do
      before { stub_any_search.to_raise(GdsApi::BaseError) }

      it "should continue with no search API data" do
        result = LicenceFacade.create_for_licences([@l1, @l2])
        expect(result[0].licence).to eq(@l1)
        expect(result[0].search_result).to eq(nil)
        expect(result[1].licence).to eq(@l2)
        expect(result[1].search_result).to eq(nil)
      end

      it "should log the error" do
        expect(Rails.logger).to receive(:warn).with(
          "GdsApi::BaseError fetching licence details from Rummager",
        )
        LicenceFacade.create_for_licences([@l1, @l2])
      end
    end

    context "when Rummager times out" do
      before { stub_any_search.to_timeout }

      it "should continue with no Rummager data" do
        result = LicenceFacade.create_for_licences([@l1, @l2])
        expect(result[0].licence).to eq(@l1)
        expect(result[0].search_result).to eq(nil)
        expect(result[1].licence).to eq(@l2)
        expect(result[1].search_result).to eq(nil)
      end

      it "should log the error" do
        expect(Rails.logger).to receive(:warn).with(
          "GdsApi::TimedOutException fetching licence details from Rummager",
        )
        LicenceFacade.create_for_licences([@l1, @l2])
      end
    end

    context "when Rummager errors" do
      before { stub_any_search.to_return(status: 503) }

      it "should continue with no Rummager data" do
        result = LicenceFacade.create_for_licences([@l1, @l2])
        expect(result[0].licence).to eq(@l1)
        expect(result[0].search_result).to eq(nil)
        expect(result[1].licence).to eq(@l2)
        expect(result[1].search_result).to eq(nil)
      end

      it "should log the error" do
        expect(Rails.logger).to receive(:warn).with(
          "GdsApi::HTTPUnavailable(503) fetching licence details from Rummager",
        )
        LicenceFacade.create_for_licences([@l1, @l2])
      end
    end
  end

  describe "attribute accessors" do
    before :each do
      @licence = FactoryBot.create(:licence)
    end

    context "with API data" do
      before :each do
        @pub_data = rummager_licence_hash(@licence.gds_id)
        @lf = LicenceFacade.new(@licence, @pub_data)
      end

      it "should be published" do
        expect(@lf.published?).to eq(true)
      end

      it "should return the API title" do
        expect(@lf.title).to eq(@pub_data["title"])
      end

      it "should return the frontend url" do
        expect(@lf.url).to eq(Plek.current.website_root + @pub_data["link"])
      end

      it "should return the API short description" do
        expect(@lf.short_description).to eq(@pub_data["licence_short_description"])
      end
    end

    context "without API data" do
      before :each do
        @lf = LicenceFacade.new(@licence, nil)
      end

      it "should not be published?" do
        expect(@lf.published?).to eq(false)
      end

      it "should return the licence name" do
        expect(@lf.title).to eq(@licence.name)
      end

      it "should return nil for the url" do
        expect(@lf.url).to eq(nil)
      end

      it "should return nil for the short_description" do
        expect(@lf.short_description).to eq(nil)
      end
    end
  end
end
