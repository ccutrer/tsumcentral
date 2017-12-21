Rails.application.routes.draw do
  root 'players#index'
  post '/:id/pause', to: 'players#pause', as: 'pause'
  delete '/:id/pause', to: 'players#unpause', as: 'unpause'
  post '/:id/runs', to: 'runs#create'
  delete '/:id/runs', to: 'runs#end'

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  get '/:id', to: 'players#show', as: 'player'
end
