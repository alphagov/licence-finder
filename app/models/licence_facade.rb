require 'gds_api/helpers'
require 'gds_api/exceptions'

class LicenceFacade
  extend GdsApi::Helpers

  def self.create_for_licences(licences)
    publisher_data = get_publisher_data(licences)
    licences.map do |l|
      new(l, publisher_data.find {|d| l.gds_id.to_s == d.licence_identifier })
    end
  end

  def self.get_publisher_data(licences)
    return [] if licences.empty?
    data = publisher_api.licences_for_ids(licences.map(&:gds_id))
    if data.nil?
      data = []
      Rails.logger.warn "Error fetching licence details from publisher"
    end
    data
  rescue GdsApi::TimedOutException
    Rails.logger.warn "Timeout fetching licence details from publisher"
    []
  end

  attr_reader :licence, :publisher_data
  def initialize(licence, publisher_data = nil)
    @licence = licence
    @publisher_data = publisher_data
  end

  def published?
    @publisher_data.present?
  end

  def title
    published? ? @publisher_data.title : @licence.name
  end

  def url
    published? ? "/#{@publisher_data.slug}" : nil
  end

  def short_description
    published? ? @publisher_data.licence_short_description : nil
  end
end
