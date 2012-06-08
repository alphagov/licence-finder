LicenceFinder::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "#{APP_SLUG}" => "licence_finder#start", :as => :start
  get "#{APP_SLUG}/sectors" => "licence_finder#sectors", :as => :sectors
  post "#{APP_SLUG}/sectors" => "licence_finder#sectors_submit"
  get "#{APP_SLUG}/activities" => "licence_finder#activities", :as => :activities
  post "#{APP_SLUG}/activities" => "licence_finder#activities_submit"
  get "#{APP_SLUG}/location" => "licence_finder#business_location", :as => :business_location
  post "#{APP_SLUG}/location" => "licence_finder#business_location_submit", :as => :business_location_submit
  get "#{APP_SLUG}/licences" => "licence_finder#licences", :as => :licences
  get "#{APP_SLUG}/browse-sectors" => "licence_finder#browse_sector_index", :as => :browse_sector_index
  get "#{APP_SLUG}/browse-sectors/:sector" => "licence_finder#browse_sector", :as => :browse_sector
  get "#{APP_SLUG}/browse-sectors/:sector_parent/:sector" => "licence_finder#browse_sector_child", :as => :browse_sector_child

  root :to => redirect("/#{APP_SLUG}", :status => 302)

end
