require 'data_importer'

RSpec.describe DataImporter::Licences do
  before :each do
    @sector = FactoryGirl.create(:sector, correlation_id: 1, layer: 3)
    @activity = FactoryGirl.create(:activity, correlation_id: 1)
  end

  describe "clean import" do
    it "imports a single licence from a file handle" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","1","0","1","0","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_licence = Licence.find_by_correlation_id(1)
      expect(imported_licence.correlation_id).to eq(1)
      expect(imported_licence.name).to eq("Licences to play music in a theatre (All UK)")
      expect(imported_licence.regulation_area).to eq("Copyright")
      imported_licence.da_england == true
      imported_licence.da_wales == true
      imported_licence.da_scotland == false
      imported_licence.da_northern_ireland == false

      imported_licence_link = LicenceLink.first
      expect(imported_licence_link.sector).to eq(@sector)
      expect(imported_licence_link.activity).to eq(@activity)
      expect(imported_licence_link.licence).to eq(imported_licence)
      expect(LicenceLink.all.length).to eq(1)
    end

    it "decodes any html entities in the data file" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Some Sector","1","Some Activity","1","Pavement licence (England &amp; Wales)","Copyright","1","0","1","0","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_licence = Licence.find_by_correlation_id(1)
      expect(imported_licence.name).to eq("Pavement licence (England & Wales)")
    end

    it "updates the licence if one with the same correlation_id already exists" do
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
      expect(imported_licence.correlation_id).to eq(1)
      expect(imported_licence.name).to eq("Licences to play music in a theatre (All UK)")
      expect(imported_licence.da_england).to be_truthy
    end
    it "fails early if the sector does not exist" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"2","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","1","1","1","1","0"
      END

      importer = DataImporter::Licences.new(source)
      expect do
        silence_stream(STDOUT) do
          importer.run
        end
      end.to raise_error(NoMethodError)
      imported_licence = Licence.find_by_correlation_id(1)
      expect(imported_licence).to eq(nil)
    end
    it "fails early if the activity does not exist" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Motor vehicle fuel retail","2","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","0","0","0","0","1"
      END

      importer = DataImporter::Licences.new(source)
      expect do
        silence_stream(STDOUT) do
          importer.run
        end
      end.to raise_error(RuntimeError)
      imported_licence = Licence.find_by_correlation_id(1)
      expect(imported_licence).to eq(nil)
    end
    it "adds links for all layer3 sectors if a layer2 sector id is provided" do
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
      expect(imported_links.length).to eq(2)
      sectors = imported_links.map(&:sector)
      expect(sectors).to include(sector1)
      expect(sectors).to include(sector2)
      expect(sectors).not_to include(sector3)
    end
    it "adds links for all layer3 sectors if a layer1 sector id is provided" do
      l1sector = FactoryGirl.create(:sector, correlation_id: 101, layer: 1)
      l2sector = FactoryGirl.create(:sector, correlation_id: 102, layer: 2, parents:[l1sector])
      sector1 = FactoryGirl.create(:sector, correlation_id: 2, layer: 3, parents: [l2sector])
      sector2 = FactoryGirl.create(:sector, correlation_id: 3, layer: 3, parents: [l2sector])
      sector3 = FactoryGirl.create(:sector, correlation_id: 4, layer: 3, parents: [])

      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"101","Motor vehicle fuel retail","1","Play background music in your premises","123-2-1","Licences to play music in a theatre (All UK)","Copyright","1","0","1","0","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_links = LicenceLink.all
      expect(imported_links.length).to eq(2)
      sectors = imported_links.map(&:sector)
      expect(sectors).to include(sector1)
      expect(sectors).to include(sector2)
      expect(sectors).not_to include(sector3)
    end
    it "does not create a new licence_link if it already exists" do
      @licence = FactoryGirl.create(:licence, gds_id: "123-2-1", name: "Test Name", da_england: false)
      licence_link = FactoryGirl.create(:licence_link, sector: @sector, activity: @activity, licence: @licence)

      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Motor vehicle fuel retail","1","Play background music in your premises","123-2-1","Licences to play music in a theatre (All UK)","Copyright","1","1","1","1","0"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      expect(LicenceLink.first).to eq(licence_link)
    end
  end

  describe "devolved authorities" do
    it "marks all devolved authority flags true if DA_ALL is set" do
      source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE","REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND","ALL_OF_UK"
"1","Motor vehicle fuel retail","1","Play background music in your premises","1","Licences to play music in a theatre (All UK)","Copyright","0","0","0","0","1"
      END

      importer = DataImporter::Licences.new(source)
      silence_stream(STDOUT) do
        importer.run
      end

      imported_licence = Licence.find_by_correlation_id(1)
      expect(imported_licence.da_england).to eq(true)
      expect(imported_licence.da_scotland).to eq(true)
      expect(imported_licence.da_wales).to eq(true)
      expect(imported_licence.da_northern_ireland).to eq(true)
    end
  end

  describe "open_data_file" do
    it "opens the input data file" do
      tmpfile = Tempfile.new("licences.csv")
      expect(DataImporter::Licences).to receive(:data_file_path).with("licences.csv").and_return(tmpfile.path)

      DataImporter::Licences.open_data_file
    end
    it "fails if the input data file does not exist" do
      expect(DataImporter::Licences).to receive(:data_file_path).with("licences.csv").and_return("/example/licences.csv")

      expect do
        DataImporter::Licences.open_data_file
      end.to raise_error(Errno::ENOENT)
    end
  end
end
