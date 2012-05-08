LicenceFinder::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/licence-finder" => "licence_finder#start"

  root :to => redirect("/licence-finder", :status => 302)

end
