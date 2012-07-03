namespace :rummager do
  desc "Reindex search engine"
  task :index => :environment do
    # TODO: remove condition when ready to go live
    unless ENV['FACTER_govuk_platform'] == "production"
      Rummageable.index [{
        "title"             => 'Licence finder',
        "description"       => "Licence finder helps UK citizens find and apply for licences of all types.",
        "format"            => "licence_finder",
        "section"           => "business",
        "subsection"        => "licences",
        "link"              => "/#{APP_SLUG}",
        "indexable_content" => "Licence finder helps UK citizens find and apply for licences of all types including temporary events notice, occasional licence, skip licence, and food premesis registration.",
      }]
    end
  end
end
