class LicenceFacade
  def self.create_for_licences(licences)
    search_results = search_licences(licences)["results"]

    licences.map do |licence|
      matching_search_data = search_results.find do |search_result|
        licence.gds_id.to_s == search_result["licence_identifier"]
      end

      new(licence, matching_search_data)
    end
  end

  def self.search_licences(licences)
    raw_data = { "results" => [] }

    return raw_data if licences.empty?

    GdsApi.search.search(
      filter_licence_identifier: licences.map(&:gds_id).map(&:to_s),
      fields: %w[title licence_short_description licence_identifier link],
    ).to_h
  rescue GdsApi::BaseError => e
    message = e.class.name
    message << "(#{e.code})" if e.respond_to?(:code)
    Rails.logger.warn "#{message} fetching licence details from Rummager"
    raw_data
  end

  attr_reader :licence, :search_result
  def initialize(licence, search_result = nil)
    @licence = licence
    @search_result = search_result
  end

  def published?
    @search_result.present?
  end

  def title
    published? ? @search_result["title"] : @licence.name
  end

  def url
    published? ? web_url : nil
  end

  def short_description
    published? ? @search_result["licence_short_description"] : nil
  end

private

  def web_url
    Plek.current.website_root + @search_result["link"]
  end
end
