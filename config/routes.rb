Rails.application.routes.draw do
  root 'players#index'
  post '/:id/pause', to: 'players#pause', as: 'pause'
  delete '/:id/pause', to: 'players#unpause', as: 'unpause'
  post '/:id/suspend', to: 'players#suspend', as: 'suspend'
  delete '/:id/suspend', to: 'players#unsuspend', as: 'unsuspend'
  post '/:id/runs', to: 'runs#create'
  delete '/:id/runs', to: 'runs#end'

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/login' => 'sessions#destroy'
  get '/change_password' => 'sessions#change_password'
  post '/change_password' => 'sessions#change_password'

  get '/:id', to: 'players#show', as: 'player'
end
