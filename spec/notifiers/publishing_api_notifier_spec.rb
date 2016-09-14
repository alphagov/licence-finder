require "services"

RSpec.describe PublishingApiNotifier do
  describe "#publish" do
    let(:presenter) { double("content_item_presenter", content_id: '69af22e0-da49-4810-9ee4-22b4666ac627', update_type: 'minor', payload: { test: :payload }) }

    it "publishes the content item" do
      expect(Services.publishing_api).to receive(:put_content).with('69af22e0-da49-4810-9ee4-22b4666ac627', test: :payload)
      expect(Services.publishing_api).to receive(:publish).with('69af22e0-da49-4810-9ee4-22b4666ac627', 'minor')

      PublishingApiNotifier.publish(presenter)
    end
  end
end
