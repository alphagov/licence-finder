require 'gds_api/exceptions'
require 'services'

class LicenceFacade
  def self.create_for_licences(licences)
    api_data = get_licence_artefacts(licences)
    licences.map do |l|
      matching_api_data = api_data['results'].find { |d| l.gds_id.to_s == d['licence_identifier'] }
      new(l, matching_api_data)
    end
  end

  def self.get_licence_artefacts(licences)
    raw_data = { 'results' => [] }

    return raw_data if licences.empty?

    Services.rummager.search(
      filter_licence_identifier: licences.map(&:gds_id).map(&:to_s),
      fields: %w(title licence_short_description licence_identifier link)
    ).to_h
  rescue GdsApi::BaseError => e
    message = e.class.name
    message << "(#{e.code})" if e.respond_to?(:code)
    Rails.logger.warn "#{message} fetching licence details from Rummager"
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
    published? ? web_url : nil
  end

  def short_description
    published? ? @artefact['licence_short_description'] : nil
  end

private

  def web_url
    Plek.find('www') + @artefact['link']
  end
end
