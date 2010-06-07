RoomTemperature::Application.routes.draw do |map|
  root :to => 'standings#index'
  
  map.resource  :standing
  map.resources :votes
end
