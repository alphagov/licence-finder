namespace :publishing_api do
  desc "Publish application metadata via publishing API"
  task :register => :environment do
    PublishingApiNotifier.publish
  end
end
