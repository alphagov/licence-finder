require 'gds_api/rummager'
require 'ostruct'

class RummagerNotifier
  def self.notify
    new.notify
  end

  def notify
    logger.info "Indexing '#{licence_finder_page.title}' in rummager..."

    SearchIndexer.call(licence_finder_page)
  end

private

  def licence_finder_page
    @licence_finder_page ||= OpenStruct.new(APPLICATION_METADATA)
  end

  def logger
    GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
  end
end
