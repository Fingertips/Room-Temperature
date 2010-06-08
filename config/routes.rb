ActionController::Routing::Routes.draw do |map|
  map.resources :rooms do |room|
    room.resources :votes
    room.resource :standing
  end
  map.resources :votes
  map.root :controller => 'rooms', :action => 'index'
  
  map.nice_room ':slug', :controller => 'standings', :action => 'index'
end
