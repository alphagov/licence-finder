require 'gds_api/panopticon'
require 'ostruct'

class PanopticonNotifier
  def self.notify
    new.notify
  end

  def notify
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "licencefinder")

    record = OpenStruct.new(APPLICATION_METADATA)
    registerer.register(record)
  end
end
