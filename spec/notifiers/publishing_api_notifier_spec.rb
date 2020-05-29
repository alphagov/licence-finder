require "spec_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.describe PublishingApiNotifier do
  include GdsApi::TestHelpers::PublishingApi

  describe "#publish" do
    it "publishes all content items" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_publish

      PublishingApiNotifier.publish

      %w[
        4ade13fa-7e79-4bee-b809-61dbe5c3aa22
        82162026-c815-4cc5-93ef-514fe467409a
        45cb0572-d71a-4c22-a84f-fdc53c2e7bc4
        e1dc997a-3afe-4180-8c8d-880e7c1ca5a1
        2cae8a3f-1231-4379-bdca-1de9b4668508
      ].each do |content_id|
        expect(a_request(:put, /content\/#{content_id}/)).to have_been_made
        expect(a_request(:post, /content\/#{content_id}\/publish/)).to have_been_made
      end
    end
  end
end
