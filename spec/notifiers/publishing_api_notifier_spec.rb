require "spec_helper"

describe PublishingApiNotifier do
  describe "#publish" do
    let(:presenter) { double("content_item_presenter", base_path: "/licence-finder", payload: {test: :payload}) }

    it "publishes the content item" do
      Services.publishing_api.should_receive(:put_content_item).with("/licence-finder", {test: :payload})

      PublishingApiNotifier.publish(presenter)
    end
  end
end
