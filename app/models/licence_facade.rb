require 'gds_api/helpers'
require 'gds_api/exceptions'

class LicenceFacade

  def self.content_api
    @content_api ||= GdsApi::ContentApi.new(Plek.current.environment)
  end

  def self.create_for_licences(licences)
    api_data = get_licence_artefacts(licences)
    licences.map do |l|
      matching_api_data = api_data['results'].find { |d| l.gds_id.to_s == d['details']['licence_identifier'] }
      new(l, matching_api_data)
    end
  end

  def self.get_licence_artefacts(licences)
    raw_data = { 'results' => [] }

    return raw_data if licences.empty?

    data = content_api.licences_for_ids(licences.map(&:gds_id))
    if data.is_a?(GdsApi::Response)
      return data.to_hash
    else 
      Rails.logger.warn "Error fetching licence details from Content API"
      return raw_data
    end
  rescue GdsApi::BaseError => e
    message = e.class.name
    message << "(#{e.code})" if e.respond_to?(:code)
    Rails.logger.warn "#{message} fetching licence details from Content API"
    raw_data
  end

  attr_reader :licence, :artefact
  def initialize(licence, artefact = nil)
    @licence = licence
    @artefact = artefact
  end

  def published?
    @artefact.present?
  end

  def title
    published? ? @artefact['title'] : @licence.name
  end

  def url
    published? ? @artefact['web_url'] : nil
  end

  def short_description
    published? ? @artefact['details']['licence_short_description'] : nil
  end
end
