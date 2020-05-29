require "gds_api/test_helpers/search"

module RummagerHelpers
  include GdsApi::TestHelpers::Search

  def rummager_licence_hash(gds_id)
    {
      "title" => "Title from search for #{gds_id}",
      "licence_short_description" => "Short description for #{gds_id}",
      "licence_identifier" => gds_id.to_s,
      "link" => "/licence-#{gds_id}",
    }
  end

  def search_response(licences)
    {
      "results" => licences.map { |l| rummager_licence_hash(l.gds_id) },
      "start" => 0,
      "total" => 1,
    }
  end

  def rummager_has_licences(output_licences, when_searching_for:)
    licences = when_searching_for
    # we sort these ids to replicate webmocks array flattening behaviour
    licence_ids = licences.map(&:gds_id).sort

    stub_any_search
      .with(query: hash_including(filter_licence_identifier: licence_ids))
      .to_return(body: search_response(output_licences).to_json)
  end
end
