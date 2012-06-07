require 'gds_api/helpers'

class LicenceFacade
  extend GdsApi::Helpers

  def self.create_for_licences(licences)
    publisher_data = publisher_api.licences_for_ids(licences.map(&:public_id))
    licences.map do |l|
      new(l, publisher_data.find {|d| l.public_id.to_s == d.licence_identifier })
    end
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
