Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(GovukHealthcheck::Mongoid)

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "#{APP_SLUG}/sectors" => "licence_finder#sectors", :as => :sectors
  get "#{APP_SLUG}/activities" => "licence_finder#activities", :as => :activities
  get "#{APP_SLUG}/location" => "licence_finder#business_location", :as => :business_location
  post "#{APP_SLUG}/location" => "licence_finder#business_location_submit", :as => :business_location_submit
  get "#{APP_SLUG}/licences" => "licence_finder#licences", :as => :licences
  get "#{APP_SLUG}/browse-sectors" => "licence_finder#browse_sector_index"
  get "#{APP_SLUG}/browse-sectors/index" => "licence_finder#browse_sector_index", :as => :browse_sector_index
  get "#{APP_SLUG}/browse-sectors/:sector" => "licence_finder#browse_sector", :as => :browse_sector
  get "#{APP_SLUG}/browse-sectors/:sector_parent/:sector" => "licence_finder#browse_sector_child", :as => :browse_sector_child
  get "#{APP_SLUG}/browse-licences" => "licence_finder#browse_licences", :as => :browse_licences

  get "#{APP_SLUG}/licences-api" => "licence_finder#licences_api", :as => :licences_api
end
