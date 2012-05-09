LicenceFinder::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/licence-finder" => "licence_finder#start"
  get "/licence-finder/sectors" => "licence_finder#sectors", :as => :sectors
  post "/licence-finder/sectors" => "licence_finder#sectors_submit"
  get "/licence-finder/activities" => "licence_finder#activities", :as => :activities
  get "/licence-finder/location" => "licence_finder#location", :as => :location
  post "/licence-finder/location" => "licence_finder#location_submit"
  get "/licence-finder/licences" => "licence_finder#licences", :as => :licences

  root :to => redirect("/licence-finder", :status => 302)

end
