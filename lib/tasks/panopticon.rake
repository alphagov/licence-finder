require 'ostruct'

namespace :panopticon do
  desc "Register application metadata with panopticon"
  task :register => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "licencefinder")

    record = OpenStruct.new(
        slug: APP_SLUG, 
        title: "Licence Finder", 
        description: "Find out which licences you might need for your activity or business.",
        section: "business",
        paths: [],
        prefixes: ["/#{APP_SLUG}"],
        state: "live",
        indexable_content: "Find out which licences you might need for your activity or business, including temporary events notice, occasional licence, skip licence, and food premises registration.")
    registerer.register(record)
  end
end
