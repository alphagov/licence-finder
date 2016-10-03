namespace :publishing_api do
  desc "Publish application metadata via publishing API"
  task publish: :environment do
    PublishingApiNotifier.publish
  end
end
