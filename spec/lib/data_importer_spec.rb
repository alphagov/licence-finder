require 'spec_helper'
require 'data_importer'

describe DataImporter do
  describe "update" do
    it "should import relevant file and then close it" do
      fh = stub()
      fh.expects(:close)
      DataImporter.stubs(:open_data_file).returns(fh)

      importer = stub()
      importer.expects(:run)
      DataImporter.expects(:new).returns(importer)

      DataImporter.update
    end

    it "should close import file even if an exception is raised" do
      fh = stub()
      fh.expects(:close)
      DataImporter.stubs(:open_data_file).returns(fh)

      importer = stub()
      importer.expects(:run).raises
      DataImporter.expects(:new).returns(importer)

      lambda do
        DataImporter.update
      end.should raise_error
    end
  end

  describe "run" do
    it "should call process_row with a hash for each line in the csv" do
      source = StringIO.new(<<-END)
"LAYER1_OID","LAYER_1_TAX_CODE","LAYER1","LAYER2_OID","LAYER_2_TAX_CODE","LAYER2","LAYER3_OID","LAYER_3_TAX_CODE","LAYER3"
"1000001","A0","Agriculture, forestry and fishing","1000002","A0.010","Agriculture","1000011","A0.010.090","Animal farming support services"
"1000004","A1","Awesome Industry","1000005","A1.010","Awesome","1000006","A1.010.090","Hurray"
      END

      importer = DataImporter.new(source)

      row1 = CSV::Row.new(
        ["LAYER1_OID","LAYER_1_TAX_CODE","LAYER1","LAYER2_OID","LAYER_2_TAX_CODE","LAYER2","LAYER3_OID","LAYER_3_TAX_CODE","LAYER3"],
        ["1000001","A0","Agriculture, forestry and fishing","1000002","A0.010","Agriculture","1000011","A0.010.090","Animal farming support services"]
      )
      importer.expects(:process_row).with(row1).returns(1)

      row2 = CSV::Row.new(
        ["LAYER1_OID","LAYER_1_TAX_CODE","LAYER1","LAYER2_OID","LAYER_2_TAX_CODE","LAYER2","LAYER3_OID","LAYER_3_TAX_CODE","LAYER3"],
        ["1000004","A1","Awesome Industry","1000005","A1.010","Awesome","1000006","A1.010.090","Hurray"]
      )
      importer.expects(:process_row).with(row2).returns(1)

      silence_stream(STDOUT) do
        importer.run
      end
    end
  end
end
