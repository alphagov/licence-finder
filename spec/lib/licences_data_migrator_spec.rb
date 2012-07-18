require 'spec_helper'
require 'licences_data_migrator'

describe LicencesDataMigrator do
  describe "migrate" do
    it "should import relevant files and then close them" do
      mfh = stub()
      mfh.expects(:close)
      LicencesDataMigrator.stubs(:open_mapping_file).returns(mfh)
      
      lfh = stub()
      lfh.expects(:close)
      LicencesDataMigrator.stubs(:open_licences_file).returns(lfh)
      
      importer = stub()
      importer.expects(:run)
      LicencesDataMigrator.expects(:new).returns(importer)

      LicencesDataMigrator.migrate
    end

    it "should close import file even if an exception is raised" do
      fh = stub()
      fh.expects(:close)
      LicencesDataMigrator.stubs(:open_mapping_file).returns(fh)

      importer = stub()
      importer.expects(:run).raises
      LicencesDataMigrator.expects(:new).returns(importer)

      lambda do
        LicencesDataMigrator.migrate
      end.should raise_error
    end
  end

  describe "run" do
  
    before(:all) do
    
      mapping_source = StringIO.new(<<-END)
"Legal_Ref_No","Formality_name","GDS ID","LGSL_ID"
"1040001","Occasional licence (1040001)","1083741393","1071"
"1620001","Temporary event notice (1620001)","1083741799","1071"
      END
      
      licences_source = StringIO.new(<<-END)
"SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE	REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND	ALL_OF_UK"
"1000228","Alcoholic drink retail","226","Sell alcoholic drinks","1083741393","Occasional licence (Scotland)","Hospitality, leisure and entertainment","0","1","0","0","0"
"1000489","Arts and entertainment facility operation","31","Exhibit films, videos or DVDs","1083741799","Temporary event notice (England &amp; Wales)","Hospitality, leisure and entertainment","1","0","1","0","0"
      END
      
      @migrator = LicencesDataMigrator.new(mapping_source, licences_source)
      
    end
    
    it "should call process_row with a hash for each line in the csv" do

      row1 = CSV::Row.new(
        ["SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE	REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND	ALL_OF_UK"],
        ["1000228","Alcoholic drink retail","226","Sell alcoholic drinks","1083741393","Occasional licence (Scotland)","Hospitality, leisure and entertainment","0","1","0","0","0"]
      )
      @migrator.expects(:process_row).with(row1).returns(1)

      row2 = CSV::Row.new(
        ["SECTOR_OID","SECTOR","BUSINESSACT_ID","ACTIVITY_TITLE","LICENCE_OID","LICENCE	REGULATION_AREA","DA_ENGLAND","DA_SCOTLAND","DA_WALES","DA_NIRELAND	ALL_OF_UK"],
        ["1000489","Arts and entertainment facility operation","31","Exhibit films, videos or DVDs","1083741799","Temporary event notice (England &amp; Wales)","Hospitality, leisure and entertainment","1","0","1","0","0"]
      )
      @migrator.expects(:process_row).with(row2).returns(1)

      #silence_stream(STDOUT) do
        @migrator.run
      #end
    end
    
    it "should cache licence identifier mappings" do
      @migrator.licence_mappings.size.should == 2
    end
    
  end
end
