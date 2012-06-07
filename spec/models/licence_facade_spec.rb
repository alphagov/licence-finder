require 'spec_helper'

describe LicenceFacade do

  describe "create_for_licences" do
    before :each do
      GdsApi::Publisher.any_instance.stubs(:licences_for_ids).returns([])
      @l1 = FactoryGirl.create(:licence)
      @l2 = FactoryGirl.create(:licence)
    end

    it "should query publisher for licence details" do
      GdsApi::Publisher.any_instance.expects(:licences_for_ids).with([@l1.public_id, @l2.public_id]).returns([])
      LicenceFacade.create_for_licences([@l1, @l2])
    end

    it "should construct Facades for each licence maintaining order" do
      result = LicenceFacade.create_for_licences([@l1, @l2])
      result.map(&:licence).should == [@l1, @l2]
    end

    it "should add the publisher details to each Facade where details exist" do
      pub_data2 = OpenStruct.new(:licence_identifier => @l2.public_id.to_s)
      GdsApi::Publisher.any_instance.stubs(:licences_for_ids).returns([pub_data2])

      result = LicenceFacade.create_for_licences([@l1, @l2])
      result[0].licence.should == @l1
      result[0].publisher_data.should == nil
      result[1].licence.should == @l2
      result[1].publisher_data.should == pub_data2
    end
  end

  describe "title" do
    before :each do
      @l = FactoryGirl.create(:licence)
    end

    it "should return the title from publisher if present" do
      lf = LicenceFacade.new(@l, OpenStruct.new(:title => "Publisher title"))
      lf.title.should == "Publisher title"
    end

    it "should return the wrapped licence's name if no publisher data" do
      lf = LicenceFacade.new(@l)

      lf.title.should == @l.name
    end
  end
end
