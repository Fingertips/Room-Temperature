ActionController::Routing::Routes.draw do |map|
  map.resource  :standing
  map.resources :votes
  map.root :controller => 'standings', :action => 'index'
end
