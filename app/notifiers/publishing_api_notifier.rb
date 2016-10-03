require 'services'

class PublishingApiNotifier
  def self.publish(presenter = LicenceFinderContentItemPresenter.new)
    new.publish(presenter)
  end

  def publish(presenter)
    Services.publishing_api.put_content(presenter.content_id, presenter.payload)
    Services.publishing_api.publish(presenter.content_id, presenter.update_type)
  end
end
