require "spec_helper"
require "data_exporter"

RSpec.describe DataExporter do
  describe ".call" do
    let!(:licence) { FactoryBot.create(:licence) }

    it "exports the gds_id" do
      exported_licences = DataExporter.call

      expect(exported_licences.first[:licence_identifier]).to eq(licence.gds_id)
    end
  end
end
