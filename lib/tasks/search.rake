desc "Interact with the search index"
task search: %w[search::index]

namespace :search do
  desc "Index all Sectors"
  task index: :environment do
    Search.instance.index_all
  end
end
