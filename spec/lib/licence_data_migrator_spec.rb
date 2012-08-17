require 'spec_helper'
require 'licence_data_migrator'

describe LicenceDataMigrator do
  before(:each) do
    @migrator = LicenceDataMigrator.new({
      "1083741393" => "1237-4-1",
      "1083741799" => "1620001",
      "1084062157" => "1580003",
      "1075329002" => "9876-3-1"
    })
  end
  
  describe "initialize" do
    it "should load the identifier mappings" do
      @migrator.licence_mappings["1083741393"].should == "1237-4-1"
    end
  end
  
  describe "run" do 
    it "should update the gds_id_id on licence records" do
      l1 = FactoryGirl.create(:licence, name: "Licence One", correlation_id: 1083741393)
      l2 = FactoryGirl.create(:licence, name: "Licence Two", correlation_id: 1075329002)
      
      silence_stream(STDOUT) do
        @migrator.run
      end
      
      l1.reload
      l2.reload
      l1.gds_id.should == "1237-4-1"
      l2.gds_id.should == "9876-3-1"
    end
    
#    it "should generate the gds_id where no suitable mapping exists" do
#      l1 = FactoryGirl.create(:licence, name: "Licence One", correlation_id: 9999999999)
#      
#      silence_stream(STDOUT) do
#        @migrator.run
#      end
#      
#      l1.gds_id.should == "3-3-1"
#    end
  end
  
  describe "country code" do
    it "should give a numeric code for the licence" do
      licence = FactoryGirl.create(:licence, da_northern_ireland: true, da_england: true)
      @migrator.country_code(licence).should == 7
      licence.da_northern_ireland = false
      licence.da_scotland = true
      licence.da_wales = true
      @migrator.country_code(licence).should == 6
      licence.da_scotland = false
      @migrator.country_code(licence).should == 5
      licence.da_wales = false
      @migrator.country_code(licence).should == 1
    end
  end
end
