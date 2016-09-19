namespace :rummager do
  desc "Indexes the licence finder page in Rummager"
  task index_all: :environment do
    RummagerNotifier.notify
  end
end
