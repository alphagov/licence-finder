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
      public_updated_at: Time.now.iso8601,
      details: {},
      routes: [
        { type: 'prefix', path: base_path }
      ]
    }
  end

private

  def metadata
    APPLICATION_METADATA
  end
end
