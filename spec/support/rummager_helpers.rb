module RummagerHelpers
  def rummager_licence_hash(gds_id)
    {
      'title' => "Title from search for #{gds_id}",
      'licence_short_description' => "Short description for #{gds_id}",
      'licence_identifier' => gds_id.to_s,
      'link' => "/licence-#{gds_id}",
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
    licence_ids = licences.map(&:gds_id)

    expect(Services.rummager).to receive(:search)
      .with(hash_including(filter_licence_identifier: licence_ids))
      .and_return(search_response(output_licences))
  end
end
