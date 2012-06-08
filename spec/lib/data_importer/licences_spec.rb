require 'spec_helper'
require 'data_importer'

describe DataImporter::Licences do
  before :each do
    @sector = FactoryGirl.create(:sector, correlation_id: 1, layer: 3)
    @activity = FactoryGirl.create(:activity, correlation_id: 1)
  end

  describe "clean import" do
    it "should import a single licence from a file handle" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","1","0","1","0","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_licence = Licence.find_by_correlation_id(1)
      imported_licence.correlation_id.should == 1
      imported_licence.name.should == "Licences to play music in a theatre (All UK)"
      imported_licence.regulation_area.should == "Copyright"
      imported_licence.da_england == true
      imported_licence.da_wales == true
      imported_licence.da_scotland == false
      imported_licence.da_northern_ireland == false

      imported_licence_link = LicenceLink.first
      imported_licence_link.sector.should == @sector
      imported_licence_link.activity.should == @activity
      imported_licence_link.licence.should == imported_licence
      LicenceLink.all.length.should == 1
    end

    it "should decode any html entities in the data file" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Some Sector","1","Some Activity","1","Pavement licence (England &amp; Wales)","Copyright","1","0","1","0","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_licence = Licence.find_by_correlation_id(1)
      imported_licence.name.should == "Pavement licence (England & Wales)"
    end

    it "should update the licence if one with the same correlation_id already exists" do
      FactoryGirl.create(:licence, correlation_id: 1, name: "Test Name", da_england: false)

      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","1","1","1","1","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_licence = Licence.find_by_correlation_id(1)
      imported_licence.correlation_id.should == 1
      imported_licence.name.should == "Licences to play music in a theatre (All UK)"
      imported_licence.da_england.should be_true
    end
    it "should fail early if the sector does not exist" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"2","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","1","1","1","1","0"
      END

      importer = DataImporter::Licences.new(source)
      lambda do
        silence_stream(STDOUT) do
          importer.run
        end
      end.should raise_error
      imported_licence = Licence.find_by_correlation_id(1)
      imported_licence.should == nil
    end
    it "should fail early if the activity does not exist" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Motor vehicle fuel retail","2","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","0","0","0","0","1"
      END

      importer = DataImporter::Licences.new(source)
      lambda do
        silence_stream(STDOUT) do
          importer.run
        end
      end.should raise_error
      imported_licence = Licence.find_by_correlation_id(1)
      imported_licence.should == nil
    end
    it "should add links for all layer3 sectors if a layer2 sector id is provided" do
      l2sector1 = FactoryGirl.create(:sector, correlation_id: 101, layer: 2)
      l2sector2 = FactoryGirl.create(:sector, correlation_id: 111, layer: 2)
      sector1 = FactoryGirl.create(:sector, correlation_id: 2, parents: [l2sector1], layer: 3)
      sector2 = FactoryGirl.create(:sector, correlation_id: 3, parents: [l2sector1], layer: 3)
      sector3 = FactoryGirl.create(:sector, correlation_id: 4, parents: [l2sector2], layer: 3)

      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"101","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","1","0","1","0","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_links = LicenceLink.all
      imported_links.length.should == 2
      sectors = imported_links.map(&:sector)
      sectors.should include(sector1)
      sectors.should include(sector2)
      sectors.should_not include(sector3)
    end
    it "should add links for all layer3 sectors if a layer1 sector id is provided" do
      l1sector = FactoryGirl.create(:sector, correlation_id: 101, layer: 1)
      l2sector = FactoryGirl.create(:sector, correlation_id: 102, layer: 2, parents:[l1sector])
      sector1 = FactoryGirl.create(:sector, correlation_id: 2, layer: 3, parents: [l2sector])
      sector2 = FactoryGirl.create(:sector, correlation_id: 3, layer: 3, parents: [l2sector])
      sector3 = FactoryGirl.create(:sector, correlation_id: 4, layer: 3, parents: [])

      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"101","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","1","0","1","0","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_links = LicenceLink.all
      imported_links.length.should == 2
      sectors = imported_links.map(&:sector)
      sectors.should include(sector1)
      sectors.should include(sector2)
      sectors.should_not include(sector3)
    end
    it "should not create a new licence_link if it already exists" do
      @licence = FactoryGirl.create(:licence, correlation_id: 1, name: "Test Name", da_england: false)
      licence_link = FactoryGirl.create(:licence_link, sector: @sector, activity: @activity, licence: @licence)

      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","1","1","1","1","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      LicenceLink.first.should == licence_link
    end
  end

  describe "devolved authorities" do
    it "should mark all devolved authority flags true if DA_ALL is set" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","0","0","0","0","1"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_licence = Licence.find_by_correlation_id(1)
      imported_licence.da_england.should == true
      imported_licence.da_scotland.should == true
      imported_licence.da_wales.should == true
      imported_licence.da_northern_ireland.should == true
    end
  end

  describe "open_data_file" do
    it "should open the input data file" do
      tmpfile = Tempfile.new("licences.csv")
      DataImporter::Licences.expects(:data_file_path).with("licences.csv").returns(tmpfile.path)

      DataImporter::Licences.open_data_file
    end
    it "should fail if the input data file does not exist" do
      DataImporter::Licences.expects(:data_file_path).with("licences.csv").returns("/example/licences.csv")

      lambda do
        DataImporter::Licences.open_data_file
      end.should raise_error(Errno::ENOENT)
    end
  end
end
