require 'spec_helper'
require 'data_importer'

RSpec.describe DataImporter do
  describe "update" do
    it "imports relevant file and then close it" do
      fh = double
      expect(fh).to receive(:close)
      allow(DataImporter).to receive(:open_data_file).and_return(fh)

      importer = double
      expect(importer).to receive(:run)
      expect(DataImporter).to receive(:new).and_return(importer)

      DataImporter.update
    end

    it "closes import file even if an exception is raised" do
      fh = double
      expect(fh).to receive(:close)
      allow(DataImporter).to receive(:open_data_file).and_return(fh)

      importer = double
      expect(importer).to receive(:run).and_raise
      expect(DataImporter).to receive(:new).and_return(importer)

      expect {
        DataImporter.update
      }.to raise_error(RuntimeError)
    end
  end

  describe "run" do
    it "calls process_row with a hash for each line in the csv" do
      source = StringIO.new(<<-END)
"LAYER1_OID","LAYER_1_TAX_CODE","LAYER1","LAYER2_OID","LAYER_2_TAX_CODE","LAYER2","LAYER3_OID","LAYER_3_TAX_CODE","LAYER3"
"1000001","A0","Agriculture, forestry and fishing","1000002","A0.010","Agriculture","1000011","A0.010.090","Animal farming support services"
"1000004","A1","Awesome Industry","1000005","A1.010","Awesome","1000006","A1.010.090","Hurray"
      END

      importer = DataImporter.new(source, StringIO.new)

      row1 = CSV::Row.new(
        %w(LAYER1_OID LAYER_1_TAX_CODE LAYER1 LAYER2_OID LAYER_2_TAX_CODE LAYER2 LAYER3_OID LAYER_3_TAX_CODE LAYER3),
        ["1000001", "A0", "Agriculture, forestry and fishing", "1000002", "A0.010", "Agriculture", "1000011", "A0.010.090", "Animal farming support services"]
      )
      expect(importer).to receive(:process_row).with(row1).and_return(1)

      row2 = CSV::Row.new(
        %w(LAYER1_OID LAYER_1_TAX_CODE LAYER1 LAYER2_OID LAYER_2_TAX_CODE LAYER2 LAYER3_OID LAYER_3_TAX_CODE LAYER3),
        ["1000004", "A1", "Awesome Industry", "1000005", "A1.010", "Awesome", "1000006", "A1.010.090", "Hurray"]
      )
      expect(importer).to receive(:process_row).with(row2).and_return(1)

      importer.run
    end
  end
end
