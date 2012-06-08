require 'spec_helper'
require 'data_importer'

describe DataImporter::Sectors do
  describe "fresh import" do
    it "should import sectors from a file handle" do
      source = StringIO.new(<<-END)
"LAYER1_OID","LAYER_1_TAX_CODE","LAYER1","LAYER2_OID","LAYER_2_TAX_CODE","LAYER2","LAYER3_OID","LAYER_3_TAX_CODE","LAYER3"
"1000001","A0","Agriculture, forestry and fishing","1000002","A0.010","Agriculture","1000011","A0.010.090","Animal farming support services"
      END

      Sector.find_by_correlation_id(1000011).should == nil

      importer = DataImporter::Sectors.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_sector = Sector.find_by_correlation_id(1000011)
      imported_sector.correlation_id.should == 1000011
      imported_sector.name.should == "Animal farming support services"

      parent_sectors = imported_sector.parents.to_a
      parent_sectors.length.should == 1
      parent_sectors[0].correlation_id.should == 1000002

      gparent_sectors = parent_sectors[0].parents.to_a
      gparent_sectors.length.should == 1
      gparent_sectors[0].correlation_id.should == 1000001
    end

    it "should avoid importing the same sector id twice" do
      source = StringIO.new(<<-END)
"LAYER1_OID","LAYER_1_TAX_CODE","LAYER1","LAYER2_OID","LAYER_2_TAX_CODE","LAYER2","LAYER3_OID","LAYER_3_TAX_CODE","LAYER3"
"1000001","A0","Agriculture, forestry and fishing","1000002","A0.010","Agriculture","1000011","A0.010.090","Animal farming support services"
"1000001","A0","Agriculture, forestry and fishing","1000002","A0.010","Agriculture","1000011","A0.010.090","Animal farming support services"
      END

      Sector.find_by_correlation_id(1000011).should == nil

      importer = DataImporter::Sectors.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      Sector.where(correlation_id: 1000011).length.should == 1
    end
  end

  describe "open_data_file" do
    it "should open the input data file" do
      tmpfile = Tempfile.new("sectors.csv")
      DataImporter::Sectors.expects(:data_file_path).with("sectors.csv").returns(tmpfile.path)

      DataImporter::Sectors.open_data_file
    end
    it "should fail if the input data file does not exist" do
      DataImporter::Sectors.expects(:data_file_path).with("sectors.csv").returns("/example/sectors.csv")

      lambda do
        DataImporter::Sectors.open_data_file
      end.should raise_error(Errno::ENOENT)
    end
  end
end
