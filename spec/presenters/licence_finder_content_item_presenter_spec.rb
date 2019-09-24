require "spec_helper"

RSpec.describe LicenceFinderContentItemPresenter do
  let(:subject) { LicenceFinderContentItemPresenter.new("/licence-finder/sectors", "4ade13fa-7e79-4bee-b809-61dbe5c3aa22") }

  describe "#base_path" do
    it "has the correct base path" do
      expect(subject.base_path).to eq "/licence-finder/sectors"
    end
  end

  describe "#payload" do
    it "is valid against the schema" do
      expect(subject.payload).to be_valid_against_schema("generic")
    end

    it "has the correct data" do
      expect(subject.payload[:title]).to eq "Licence Finder"
    end

    it "uses a prefix route" do
      expect(subject.payload[:routes].first[:type]).to eql("prefix")
    end
  end

  describe "#content_id" do
    it "has the expected content_id" do
      expect(subject.content_id).to eql("4ade13fa-7e79-4bee-b809-61dbe5c3aa22")
    end
  end
end
