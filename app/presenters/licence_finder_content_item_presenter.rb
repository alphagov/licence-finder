class LicenceFinderContentItemPresenter
  def base_path
    "/" + metadata[:slug]
  end

  def payload
    {
      title: metadata[:title],
      description: metadata[:description],
      content_id: metadata[:content_id],
      format: 'placeholder_licence_finder',
      publishing_app: 'licencefinder',
      rendering_app: 'licencefinder',
      update_type: 'minor',
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
