class LicenceFinderContentItemPresenter
  attr_reader :base_path, :content_id

  def initialize(base_path, content_id)
    @base_path = base_path
    @content_id = content_id
  end

  def payload
    {
      base_path: base_path,
      title: metadata[:title],
      description: metadata[:description],
      document_type: "license_finder",
      schema_name: "generic",
      publishing_app: "licencefinder",
      rendering_app: "licencefinder",
      locale: "en",
      details: {},
      routes: [
        { type: "prefix", path: base_path },
      ],
      update_type: "minor",
    }
  end

private

  def metadata
    APPLICATION_METADATA
  end
end
