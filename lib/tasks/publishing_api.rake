namespace :publishing_api do
  desc "Creates/updates Licence Finder pages in the Publishing API"
  task publish: :environment do
    PublishingApiNotifier.publish
  end
end
