require 'ostruct'

namespace :panopticon do
  desc "Register application metadata with panopticon"
  task :register => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "licencefinder")

    record = OpenStruct.new(slug: APP_SLUG, title: "Licence Finder", need_id: "B90", section: "licences")
    registerer.register(record)
  end
end
