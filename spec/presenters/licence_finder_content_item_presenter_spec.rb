require 'spec_helper'

describe LicenceFinderContentItemPresenter do
  let(:subject) { LicenceFinderContentItemPresenter.new }

  describe "#base_path" do
    it "has the correct base path" do
      subject.base_path.should eq "/licence-finder"
    end
  end

  describe "#payload" do
    it "is valid against the schema" do
      subject.payload.should be_valid_against_schema("placeholder")
    end

    it "has the correct data" do
      subject.payload[:title].should eq "Licence Finder"
      subject.payload[:content_id].should eq "69af22e0-da49-4810-9ee4-22b4666ac627"
    end
  end
end
