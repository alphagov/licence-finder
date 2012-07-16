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
        need_id: "B90", 
        section: "business",
        paths: [APP_SLUG],
        prefixes: [APP_SLUG],
        live: true, 
        indexable_content: "Find out which licences you might need for your activity or business, including temporary events notice, occasional licence, skip licence, and food premesis registration.")
    registerer.register(record)
  end
end
