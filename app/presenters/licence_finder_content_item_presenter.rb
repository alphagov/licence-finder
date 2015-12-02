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
      content_id: content_id,
      format: 'placeholder_licence_finder',
      publishing_app: 'licencefinder',
      rendering_app: 'licencefinder',
      update_type: update_type,
      locale: 'en',
      public_updated_at: Time.now.iso8601,
      routes: [
        { type: 'exact', path: base_path }
      ]
    }
  end

private

  def metadata
    APPLICATION_METADATA
  end
end
