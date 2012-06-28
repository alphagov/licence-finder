namespace :rummager do
  desc "Reindex search engine"
  task :index => :environment do
    # TODO: remove condition when ready to go live
    unless ENV['FACTER_govuk_platform'] == "production"
      # TODO: Update copy here
      Rummageable.index [{
        "title"             => 'Licence Finder',
        "description"       => "Find licences",
        "format"            => "licence_finder",
        "section"           => "licences",
        "subsection"        => "other",
        "link"              => "/#{APP_SLUG}",
        "indexable_content" => "Licence finder find licences",
      }]
    end
  end
end
