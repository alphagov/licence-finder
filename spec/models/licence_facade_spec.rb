RSpec.describe LicenceFacade, type: :model do
  include GdsApi::TestHelpers::ContentApi

  def json_response_data(*licences)
    {
      "_response_info" => { "status" => "ok" },
      "description" => "Licences",
      "total" => 1,
      "start_index" => 1,
      "page_size" => 1,
      "current_page" => 1,
      "pages" => 1,
      "results" => licences.map { |l| content_api_licence_hash(l.gds_id) }
    }.to_json
  end

  def api_response_data(licence)
    response = OpenStruct.new(
      code: 200,
      body: json_response_data(licence)
    )
    GdsApi::Response.new(response)
  end

  describe "create_for_licences" do
    before :each do
      allow_any_instance_of(GdsApi::ContentApi).to receive(:licences_for_ids).and_return([])
      @l1 = FactoryGirl.create(:licence)
      @l2 = FactoryGirl.create(:licence)
    end

    it "should query Content API for licence details" do
      expect_any_instance_of(GdsApi::ContentApi).to receive(:licences_for_ids).with([@l1.gds_id, @l2.gds_id]).and_return([])
      LicenceFacade.create_for_licences([@l1, @l2])
    end

    it "should skip querying Content API if not given any licences" do
      allow_any_instance_of(GdsApi::ContentApi).to receive(:licences_for_ids).and_call_original # clear the stub above, otherwise the next line won't work
      expect_any_instance_of(GdsApi::ContentApi).not_to receive(:licences_for_ids)
      LicenceFacade.create_for_licences([])
    end

    it "should construct Facades for each licence maintaining order" do
      result = LicenceFacade.create_for_licences([@l1, @l2])
      expect(result.map(&:licence)).to eq([@l1, @l2])
    end

    it "should add the Content API details to each Facade where details exist" do
      pub_data2 = api_response_data(@l2)
      expect_any_instance_of(GdsApi::ContentApi).to receive(:licences_for_ids).and_return(pub_data2)

      result = LicenceFacade.create_for_licences([@l1, @l2])
      expect(result[0].licence).to eq(@l1)
      expect(result[0].artefact).to eq(nil)
      expect(result[1].licence).to eq(@l2)
      expect(result[1].artefact).to eq(content_api_licence_hash(@l2.gds_id))
    end

    context "when Content API returns nil" do
      before :each do
        allow_any_instance_of(GdsApi::ContentApi).to receive(:licences_for_ids).and_return(nil)
      end

      it "should continue with no content API data" do
        result = LicenceFacade.create_for_licences([@l1, @l2])
        expect(result[0].licence).to eq(@l1)
        expect(result[0].artefact).to eq(nil)
        expect(result[1].licence).to eq(@l2)
        expect(result[1].artefact).to eq(nil)
      end

      it "should log the error" do
        expect(Rails.logger).to receive(:warn).with("Error fetching licence details from Content API")
        LicenceFacade.create_for_licences([@l1, @l2])
      end
    end

    context "when Content API times out" do
      before :each do
        allow_any_instance_of(GdsApi::ContentApi).to receive(:licences_for_ids).and_raise(GdsApi::TimedOutException)
      end

      it "should continue with no Content API data" do
        result = LicenceFacade.create_for_licences([@l1, @l2])
        expect(result[0].licence).to eq(@l1)
        expect(result[0].artefact).to eq(nil)
        expect(result[1].licence).to eq(@l2)
        expect(result[1].artefact).to eq(nil)
      end

      it "should log the error" do
        expect(Rails.logger).to receive(:warn).with("GdsApi::TimedOutException fetching licence details from Content API")
        LicenceFacade.create_for_licences([@l1, @l2])
      end
    end

    context "when Content API errors" do
      before :each do
        allow_any_instance_of(GdsApi::ContentApi).to receive(:licences_for_ids).and_raise(GdsApi::HTTPErrorResponse.new(503))
      end

      it "should continue with no API data" do
        result = LicenceFacade.create_for_licences([@l1, @l2])
        expect(result[0].licence).to eq(@l1)
        expect(result[0].artefact).to eq(nil)
        expect(result[1].licence).to eq(@l2)
        expect(result[1].artefact).to eq(nil)
      end

      it "should log the error" do
        expect(Rails.logger).to receive(:warn).with("GdsApi::HTTPErrorResponse(503) fetching licence details from Content API")
        LicenceFacade.create_for_licences([@l1, @l2])
      end
    end
  end

  describe "attribute accessors" do
    before :each do
      @licence = FactoryGirl.create(:licence)
    end

    context "with API data" do
      before :each do
        @pub_data = content_api_licence_hash(@licence.gds_id)
        @lf = LicenceFacade.new(@licence, @pub_data)
      end

      it "should be published" do
        expect(@lf.published?).to eq(true)
      end

      it "should return the API title" do
        expect(@lf.title).to eq(@pub_data['title'])
      end

      it "should return the frontend url" do
        expect(@lf.url).to eq(@pub_data['web_url'])
      end

      it "should return the API short description" do
        expect(@lf.short_description).to eq(@pub_data['details']['licence_short_description'])
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
