require 'ostruct'
require 'services'

class PanopticonNotifier
  def self.notify
    new.notify
  end

  def notify
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    record = OpenStruct.new(APPLICATION_METADATA)
    Services.panopticon_registerer.register(record)
  end
end
