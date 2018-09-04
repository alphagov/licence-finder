require 'rails_helper'
require 'data_importer'

RSpec.describe DataImporter::Activities do
  describe "fresh import" do
    it "should import activities from a file handle" do
      source = StringIO.new(<<~CSV)
        "SECTOR_OID","SECTOR","BUSINSS_ACT_ID","ACTIVITY_TITLE"
        "1000431","Nutritionist services","362","Practise as a dietitian "
        "1000431","Nutritionist services","1002","Use CCTV systems"
      CSV

      sector = FactoryBot.create(:sector, correlation_id: 1000431)

      importer = DataImporter::Activities.new(source, StringIO.new)
      importer.run

      imported_activity1 = Activity.find_by_correlation_id(362)
      expect(imported_activity1.correlation_id).to eq(362)
      expect(imported_activity1.name).to eq("Practise as a dietitian ")

      imported_activity2 = Activity.find_by_correlation_id(1002)
      expect(imported_activity2.correlation_id).to eq(1002)
      expect(imported_activity2.name).to eq("Use CCTV systems")

      sector.reload
      expect(sector.activities).to eq([imported_activity1, imported_activity2])
    end

    it "should avoid importing the same activity id more than once" do
      source = StringIO.new(<<~CSV)
        "SECTOR_OID","SECTOR","BUSINSS_ACT_ID","ACTIVITY_TITLE"
        "1000431","Nutritionist services","362","Practise as a dietitian "
        "1000431","Nutritionist services","362","Practise as a dietitian "
      CSV

      FactoryBot.create(:sector, correlation_id: 1000431)

      importer = DataImporter::Activities.new(source, StringIO.new)
      importer.run

      expect(Activity.where(correlation_id: 362).length).to eq(1)
    end
  end

  describe "open_data_file" do
    it "should open the input data file" do
      tmpfile = Tempfile.new("activities.csv")
      expect(DataImporter::Activities).to receive(:data_file_path).with("activities.csv").and_return(tmpfile.path)

      DataImporter::Activities.open_data_file
    end
    it "should fail if the input data file does not exist" do
      expect(DataImporter::Activities).to receive(:data_file_path).with("activities.csv").and_return("/example/activities.csv")

      expect {
        DataImporter::Activities.open_data_file
      }.to raise_error(Errno::ENOENT)
    end
  end
end
