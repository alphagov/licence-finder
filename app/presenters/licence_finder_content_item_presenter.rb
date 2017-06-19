class LicenceFinderContentItemPresenter
  def base_path
    "/" + metadata[:slug]
  end

  def content_id
    metadata[:content_id]
  end

  def update_type
    'minor'
  end

  def route_type
    'exact'
  end

  def payload
    {
      base_path: base_path,
      title: metadata[:title],
      description: metadata[:description],
      document_type: 'license_finder',
      schema_name: 'generic',
      publishing_app: 'licencefinder',
      rendering_app: 'licencefinder',
      locale: 'en',
      details: {},
      routes: [
        { type: route_type, path: base_path }
      ]
    }
  end

private

  def metadata
    APPLICATION_METADATA
  end
end
