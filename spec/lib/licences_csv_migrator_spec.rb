require 'spec_helper'
require 'licences_csv_migrator'

describe LicencesCsvMigrator do
  before(:all) do
    
    mappings_headers = ["correlation_id", "legal_ref_id", "gds_id"]
    @mappings = {
      "1074535596" => "374-6-1", 
      "1075328394" => "375-6-1" 
    }

    source = <<-END
"LICENCE_OID","LICENCE"
"1074535596","Licence One"
"1075328394","Licence Two"
"9999999999","Licence Three"
END

    @licence_data = CSV.parse(source, headers: true)
    
    @migrated_csv = []
    @unmigrated_csv = []
    
    @migrator = LicencesCsvMigrator.new(@migrated_csv, @unmigrated_csv, @licence_data, @mappings)
  end
  
  describe "run" do
    before(:all) do
      silence_stream(STDOUT) do
        @migrator.run
      end
    end
    
    # TODO: Lookup by header bOrked
    #
    it "add rows matching a mapping to migrated_csv" do
      @migrated_csv.second[0].should == "374-6-1"
      @migrated_csv.third[0].should == "375-6-1"
    end
    it "add rows not matching a mapping to unmigrated_csv" do
      @unmigrated_csv.second[0].should == "9999999999"
    end
  end
  
end
