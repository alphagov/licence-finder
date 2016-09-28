namespace :rummager do
  desc "Indexes the licence finder page in Rummager"
  task index: :environment do
    RummagerNotifier.notify
  end
end
