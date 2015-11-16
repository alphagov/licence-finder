require 'services'

class PublishingApiNotifier
  def self.publish(presenter=LicenceFinderContentItemPresenter.new)
    new.publish(presenter)
  end

  def publish(presenter)
    Services.publishing_api.put_content_item(presenter.base_path, presenter.payload)
  end
end
