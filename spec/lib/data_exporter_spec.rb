require "spec_helper"
require "data_exporter"

RSpec.describe DataExporter do
  describe ".call" do
    let!(:licence) { FactoryBot.create(:licence) }

    it "exports the gds_id" do
      exported_licences = DataExporter.call

      expect(exported_licences.first[:licence_identifier]).to eq(licence.gds_id)
    end

    it "exports the applicable devolved administrations for each licence" do
      exported_licences = DataExporter.call

      expect(exported_licences.first[:locations]).to include("england")
      expect(exported_licences.first[:locations]).to_not include("wales")
      expect(exported_licences.first[:locations]).to_not include("scotland")
      expect(exported_licences.first[:locations]).to_not include("northern-ireland")
    end

    describe "level two sectors" do
      let!(:sector_layer_1) { FactoryBot.create(:sector, name: "Layer 1 Sector", layer: 1) }
      let!(:sector_layer_2) { FactoryBot.create(:sector, name: "Layer 2 Sector", layer: 2, parent_ids: [sector_layer_1.id]) }
      let!(:sector_layer_3) { FactoryBot.create(:sector, name: "Layer 3 Sector", layer: 3, parent_ids: [sector_layer_2.id]) }
      let!(:licence_link) { FactoryBot.create(:licence_link, sector: sector_layer_3, licence:) }

      it "only exports the level two sectors the licence is tagged to" do
        exported_licences = DataExporter.call

        expect(exported_licences.first[:industry_sectors].size).to eq(1)
        expect(exported_licences.first[:industry_sectors]).to include(sector_layer_2.name.parameterize)
        expect(exported_licences.first[:industry_sectors]).to_not include(sector_layer_1.name.parameterize)
        expect(exported_licences.first[:industry_sectors]).to_not include(sector_layer_3.name.parameterize)
      end

      it "removes duplicate level two sectors the licence is tagged to" do
        another_sector_layer_3 = FactoryBot.create(:sector, name: "Layer 3 Sector", layer: 3, parent_ids: [sector_layer_2.id])
        FactoryBot.create(:licence_link, sector: another_sector_layer_3, licence:)

        exported_licences = DataExporter.call

        expect(exported_licences.first[:industry_sectors].size).to eq(1)
        expect(exported_licences.first[:industry_sectors]).to include(sector_layer_2.name.parameterize)
      end
    end
  end
end
