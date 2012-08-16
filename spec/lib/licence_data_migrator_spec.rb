require 'spec_helper'
require 'licence_data_migrator'

describe LicenceDataMigrator do
  before(:all) do
    LicenceDataMigrator.stub(:load_mappings).and_return({
      "1083741393" => "1040001",
      "1083741799" => "1620001",
      "1084062157" => "1580003",
      "1075329002" => "1610001"
    })
    @migrator = LicenceDataMigrator.new
  end
  
  describe "initialize" do
    it "should load the identifier mappings" do
      @migrator.licence_mappings["1083741393"].should == "1040001"
    end
  end
  
  describe "run" do 
    it "should update the legal_ref_id on licence records" do
      l1 = FactoryGirl.create(:licence, name: "Licence One", correlation_id: 1083741393)
      l2 = FactoryGirl.create(:licence, name: "Licence Two", correlation_id: 1075329002)
      
      silence_stream(STDOUT) do
        @migrator.run
      end
      
      l1.reload
      l2.reload
      l1.gds_id.should == "1040001"
      l2.gds_id.should == "1610001"
    end
    
    it "should not nullify the gds_id where no suitable mapping exists" do
      l1 = FactoryGirl.create(:licence, name: "Licence One", correlation_id: 9999999999, gds_id: "123-2-1")
      
      silence_stream(STDOUT) do
        @migrator.run
      end
      
      l1.gds_id.should == "123-2-1"
    end
  end
end
