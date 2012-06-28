namespace :router do
  task :router_environment => :environment do
    require 'logger'
    @logger = Logger.new STDOUT
    @logger.level = Logger::DEBUG

    @router = Router.new "http://router.cluster:8080/router", :logger => @logger
  end

  task :register_application => :router_environment do
    platform = ENV['FACTER_govuk_platform']
    # TODO: remove condition when ready to go live
    unless platform == "production"
      url = "licencefinder.#{platform}.alphagov.co.uk"
      @logger.info "Registering application..."
      @router.update_application "licencefinder", url
    end
  end

  task :register_routes => :router_environment do
    # TODO: remove condition when ready to go live
    unless ENV['FACTER_govuk_platform'] == "production"
      @router.create_route APP_SLUG, 'prefix', 'licencefinder'
    end
  end

  desc "Register smartanswers application and routes with the router (run this task on server in cluster)"
  task :register => [ :register_application, :register_routes ]
end
