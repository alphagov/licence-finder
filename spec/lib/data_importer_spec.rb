require 'spec_helper'
require 'data_importer'

describe DataImporter do
  describe "import_for" do
    before do
      activity = [{
        "_id" => "50a50d2c686c823d7c0001fa",
        "correlation_id" => 362,
        "name" => "Practise as a dietitian",
        "public_id" => 1,
        "sector_ids" => ["50a50d2a686c823d7c00007d","50a50d2a686c823d7c00007a"]
      }]
      File.stub(:open) { StringIO.new(activity.to_json) }
    end

    it "should open a json file by infering the model name" do
      File.should_receive(:open).with("data/json/activity.json", "rb").once
      DataImporter.import_for(Activity)
    end

    it "should parse the json file" do
      JSON.should_receive(:parse).once
      DataImporter.import_for(Activity)
    end

    it "should create a record for the model name being called" do
      Activity.should_receive(:create!)
        .with(hash_including(:correlation_id => 362, :public_id => 1))
        .once
      DataImporter.import_for(Activity)
    end
  end
end
