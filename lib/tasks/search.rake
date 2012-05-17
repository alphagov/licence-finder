
desc "Interact with the search index"
task :search => %w(search::index)

namespace :search do
  desc "Index all Sectors"
  task :index => :environment do
    $search.index_all
  end
end