namespace :rummager do
  desc "Reindex search engine"
  task :index => :environment do
    Rummageable.index [{
      "title"             => 'Licence finder',
      "description"       => "Find out which licences you might need for your activity or business.",
      "format"            => "licence_finder",
      "section"           => "business",
      "subsection"        => "licences",
      "link"              => "/#{APP_SLUG}",
      "indexable_content" => "Find out which licences you might need for your activity or business, including temporary events notice, occasional licence, skip licence, and food premesis registration.",
    }]
  end
end
