ActionController::Routing::Routes.draw do |map|
  map.resources :rooms
  map.resource  :standing
  map.resources :votes
  map.root :controller => 'rooms', :action => 'index'
  
  map.nice_room ':slug', :controller => 'standings', :action => 'index'
end
