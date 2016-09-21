require 'rails_helper'
require 'gds_api/test_helpers/rummager'

RSpec.describe SearchIndexer do
  include GdsApi::TestHelpers::Rummager

  before do
    stub_any_rummager_post_with_queueing_enabled
  end

  it 'indexes the licence finder page in rummager' do
    licence_finder_page = OpenStruct.new(APPLICATION_METADATA)
    described_class.call(licence_finder_page)

    assert_rummager_posted_item(
      _type: 'edition',
      _id: "/#{licence_finder_page.slug}",
      rendering_app: "licencefinder",
      publishing_app: "licencefinder",
      format: "custom-application",
      title: licence_finder_page.title,
      description: licence_finder_page.description,
      indexable_content: licence_finder_page.indexable_content,
      link: "/#{licence_finder_page.slug}"
    )
  end
end
