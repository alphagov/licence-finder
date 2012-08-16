require 'spec_helper'
require 'licences_csv_migrator'

describe LicencesCsvMigrator do
  before(:all) do
    
    mappings_headers = ["Legal_Ref_No", "GDS ID"]
    @mappings = [
      CSV::Row.new(mappings_headers, ["1040001", "1083741393"]),
      CSV::Row.new(mappings_headers, ["1610001", "1075329002"])
    ]
    
    licence_headers =["LICENCE_OID","LICENCE"]
    @licence_data = [
      CSV::Row.new(licence_headers, ["1083741393", "Licence One"]),
      CSV::Row.new(licence_headers, ["1075329002", "Licence Two"]),
      CSV::Row.new(licence_headers, ["9999999999", "Licence Three"])
    ]
    
    @migrated_csv = []
    @unmigrated_csv = []
    
    @migrator = LicencesCsvMigrator.new(@migrated_csv, @unmigrated_csv, @licence_data, @mappings)
  end
  
  describe "initialize" do
    it "should load mappings" do
      @migrator.licence_mappings.size.should == 2
    end
  end
  
  describe "run" do
    before(:all) do
      silence_stream(STDOUT) do
        @migrator.run
      end
    end
#    it "add rows matching a mapping to migrated_csv" do
#      @migrated_csv.first['LICENCE_OID'].should == "1040001"
#      @migrated_csv.second['LICENCE_OID'].should == "1610001"
#    end
#    it "add rows not matching a mapping to unmigrated_csv" do
#      @unmigrated_csv.first['LICENCE_OID'].should == "9999999999"
#    end
  end
  
end
