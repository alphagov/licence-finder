class SearchPayloadPresenter
  attr_reader :licence_finder_page
  delegate :slug,
           :title,
           :description,
           :indexable_content,
           :content_id,
           to: :licence_finder_page

  def initialize(licence_finder_page)
    @licence_finder_page = licence_finder_page
  end

  def self.call(licence_finder_page)
    new(licence_finder_page).call
  end

  def call
    {
      content_id: content_id,
      rendering_app: 'licencefinder',
      publishing_app: 'licencefinder',
      format: 'custom-application',
      title: title,
      description: description,
      indexable_content: indexable_content,
      link: "/#{slug}"
    }
  end
end
