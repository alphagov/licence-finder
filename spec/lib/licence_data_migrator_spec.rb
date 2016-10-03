require 'rails_helper'
require 'licence_data_migrator'

RSpec.describe LicenceDataMigrator do
  before(:each) do
    @migrator = LicenceDataMigrator.new({
      "1083741393" => "1237-4-1",
      "1083741799" => "1620001",
      "1084062157" => "1580003",
      "1075329002" => "9876-3-1"
      },
      StringIO.new
    )
  end

  describe "initialize" do
    it "loads the identifier mappings" do
      expect(@migrator.licence_mappings["1083741393"]).to eq("1237-4-1")
    end
  end

  describe "run" do
    it "updates the gds_id_id on licence records" do
      l1 = FactoryGirl.create(:licence, name: "Licence One", correlation_id: 1083741393)
      l2 = FactoryGirl.create(:licence, name: "Licence Two", correlation_id: 1075329002)

      @migrator.run

      l1.reload
      l2.reload
      expect(l1.gds_id).to eq("1237-4-1")
      expect(l2.gds_id).to eq("9876-3-1")
    end
  end

  describe "country code" do
    it "gives a numeric code for the licence" do
      licence = FactoryGirl.create(:licence, da_northern_ireland: true, da_england: true)
      expect(@migrator.country_code(licence)).to eq(7)
      licence.da_northern_ireland = false
      licence.da_scotland = true
      licence.da_wales = true
      expect(@migrator.country_code(licence)).to eq(6)
      licence.da_scotland = false
      expect(@migrator.country_code(licence)).to eq(5)
      licence.da_wales = false
      expect(@migrator.country_code(licence)).to eq(1)
    end
  end
end
