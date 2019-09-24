require "rails_helper"
require "data_importer"

RSpec.describe DataImporter::Sectors do
  describe "fresh import" do
    it "imports sectors from a file handle" do
      source = StringIO.new(<<~CSV)
        "LAYER1_OID","LAYER_1_TAX_CODE","LAYER1","LAYER2_OID","LAYER_2_TAX_CODE","LAYER2","LAYER3_OID","LAYER_3_TAX_CODE","LAYER3"
        "1000001","A0","Agriculture, forestry and fishing","1000002","A0.010","Agriculture","1000011","A0.010.090","Animal farming support services"
      CSV

      expect(Sector.find_by_correlation_id(1000011)).to eq(nil)

      importer = DataImporter::Sectors.new(source, StringIO.new)
      importer.run

      imported_sector = Sector.find_by_correlation_id(1000011)
      expect(imported_sector.correlation_id).to eq(1000011)
      expect(imported_sector.name).to eq("Animal farming support services")

      parent_sectors = imported_sector.parents.to_a
      expect(parent_sectors.length).to eq(1)
      expect(parent_sectors[0].correlation_id).to eq(1000002)

      gparent_sectors = parent_sectors[0].parents.to_a
      expect(gparent_sectors.length).to eq(1)
      expect(gparent_sectors[0].correlation_id).to eq(1000001)
    end

    it "avoids importing the same sector id twice" do
      source = StringIO.new(<<~CSV)
        "LAYER1_OID","LAYER_1_TAX_CODE","LAYER1","LAYER2_OID","LAYER_2_TAX_CODE","LAYER2","LAYER3_OID","LAYER_3_TAX_CODE","LAYER3"
        "1000001","A0","Agriculture, forestry and fishing","1000002","A0.010","Agriculture","1000011","A0.010.090","Animal farming support services"
        "1000001","A0","Agriculture, forestry and fishing","1000002","A0.010","Agriculture","1000011","A0.010.090","Animal farming support services"
      CSV

      expect(Sector.find_by_correlation_id(1000011)).to eq(nil)

      importer = DataImporter::Sectors.new(source, StringIO.new)
      importer.run

      expect(Sector.where(correlation_id: 1000011).length).to eq(1)
    end
  end

  describe "open_data_file" do
    it "opens the input data file" do
      tmpfile = Tempfile.new("sectors.csv")
      expect(DataImporter::Sectors).to receive(:data_file_path).with("sectors.csv").and_return(tmpfile.path)

      DataImporter::Sectors.open_data_file
    end
    it "fails if the input data file does not exist" do
      expect(DataImporter::Sectors).to receive(:data_file_path).with("sectors.csv").and_return("/example/sectors.csv")

      expect {
        DataImporter::Sectors.open_data_file
      }.to raise_error(Errno::ENOENT)
    end
  end
end
