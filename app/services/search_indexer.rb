require 'services'

class SearchIndexer
  attr_reader :licence_finder_page
  delegate :slug, to: :licence_finder_page

  def initialize(licence_finder_page)
    @licence_finder_page = licence_finder_page
  end

  def self.call(licence_finder_page)
    new(licence_finder_page).call
  end

  def call
    Services.rummager.add_document(document_type, document_id, payload)
  end

private

  def document_type
    'edition'
  end

  def document_id
    "/#{slug}"
  end

  def payload
    SearchPayloadPresenter.call(licence_finder_page)
  end
end
