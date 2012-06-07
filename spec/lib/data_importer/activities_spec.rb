require 'spec_helper'
require 'data_importer'

describe DataImporter::Activities do
  describe "fresh import" do
    it "should import activities from a file handle" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINSS_ACT_ID","ACTIVITY_TITLE"
"1000431","Nutritionist services","362","Practise as a dietitian "
"1000431","Nutritionist services","1002","Use CCTV systems"
      END

      sector = FactoryGirl.create(:sector, correlation_id: 1000431)

      importer = DataImporter::Activities.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_activity1 = Activity.find_by_correlation_id(362)
      imported_activity1.correlation_id.should == 362
      imported_activity1.name.should == "Practise as a dietitian "

      imported_activity2 = Activity.find_by_correlation_id(1002)
      imported_activity2.correlation_id.should == 1002
      imported_activity2.name.should == "Use CCTV systems"

      sector.reload
      sector.activities.should == [imported_activity1, imported_activity2]
    end

    it "should avoid importing the same activity id more than once" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINSS_ACT_ID","ACTIVITY_TITLE"
"1000431","Nutritionist services","362","Practise as a dietitian "
"1000431","Nutritionist services","362","Practise as a dietitian "
      END

      sector = FactoryGirl.create(:sector, correlation_id: 1000431)

      importer = DataImporter::Activities.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      Activity.where(correlation_id: 362).length.should == 1
    end
  end

  describe "open_data_file" do
    it "should open the input data file" do
      tmpfile = Tempfile.new("activities.csv")
      DataImporter::Activities.expects(:data_file_path).with("activities.csv").returns(tmpfile.path)

      DataImporter::Activities.open_data_file
    end
    it "should fail if the input data file does not exist" do
      DataImporter::Activities.expects(:data_file_path).with("activities.csv").returns("/example/activities.csv")

      lambda do
        DataImporter::Activities.open_data_file
      end.should raise_error(Errno::ENOENT)
    end
  end
end
