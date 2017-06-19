class LicenceFinderFormContentItemPresenter < LicenceFinderContentItemPresenter
  attr_reader :base_path, :content_id

  def initialize(base_path, content_id)
    @base_path = base_path
    @content_id = content_id
  end

  def route_type
    'prefix'
  end
end
