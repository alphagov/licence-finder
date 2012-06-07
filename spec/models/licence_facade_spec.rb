require 'spec_helper'

describe LicenceFacade do
  describe "create_for_licences" do
    before :each do
      @l1 = FactoryGirl.create(:licence)
      @l2 = FactoryGirl.create(:licence)
    end

    it "should return an array of LicenceFacade's, one for each licence" do
      result = LicenceFacade.create_for_licences([@l1, @l2])

      result.map(&:licence).should =~ [@l1, @l2]
    end

  end

  describe "title" do
    it "should return the wrapped licence's name" do
      l = FactoryGirl.create(:licence)
      lf = LicenceFacade.new(l)

      lf.title.should == l.name
    end
  end
end
