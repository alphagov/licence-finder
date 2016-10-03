require 'gds_api/publishing_api_v2'
require 'gds_api/rummager'
require 'gds_api/content_api'
require 'gds_api/panopticon'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end

  def self.rummager
    @rummager ||= GdsApi::Rummager.new(Plek.find("rummager"))
  end

  def self.content_api
    @content_api ||= GdsApi::ContentApi.new(Plek.current.find("contentapi"))
  end

  def self.panopticon_registerer
    @panopticon_registerer ||= GdsApi::Panopticon::Registerer.new(owning_app: "licencefinder")
  end
end
