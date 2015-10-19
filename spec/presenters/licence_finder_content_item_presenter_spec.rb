describe LicenceFinderContentItemPresenter do
  let(:subject) { LicenceFinderContentItemPresenter.new }

  describe "#base_path" do
    it "has the correct base path" do
      expect(subject.base_path).to eq "/licence-finder"
    end
  end

  describe "#payload" do
    it "is valid against the schema" do
      expect(subject.payload).to be_valid_against_schema("placeholder")
    end

    it "has the correct data" do
      expect(subject.payload[:title]).to eq "Licence Finder"
      expect(subject.payload[:content_id]).to eq "69af22e0-da49-4810-9ee4-22b4666ac627"
    end
  end
end
