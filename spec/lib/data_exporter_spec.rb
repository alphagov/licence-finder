require 'spec_helper'
require 'data_exporter'

describe DataExporter do
  describe "export_for" do
    before do
      File.stub!(:open).and_return(true)
    end

    it "should iterate over all class data" do
      Licence.should_receive(:all).once.and_return([])
      DataExporter.export_for(Licence)
    end

    it "should save the class data as json" do
      Licence.should_receive(:all).once.and_return([{:name => "An example licence"}])
      DataExporter.should_receive(:save_to_file).once
        .with("[{\"name\":\"An example licence\"}]", "licence")
        .and_return(true)

      DataExporter.export_for(Licence)
    end

    it "should use the class name to generate the filename" do
      Licence.should_receive(:all).once.and_return([{:name => "An example licence"}])
      File.should_receive(:open).once.with("data/json/licence.json", "w")

      DataExporter.export_for(Licence)
    end
  end
end
