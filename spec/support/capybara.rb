require "capybara/poltergeist"

Capybara.server = :webrick

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--ssl-protocol=TLSv1'])
end

Capybara.javascript_driver = :poltergeist

RSpec.configuration.include Capybara::DSL, type: :request
