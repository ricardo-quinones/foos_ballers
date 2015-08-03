Rails.application.routes.draw do
  root 'home#leaderboard'

  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      resources :sessions, only: [:create] do
        delete :destroy, on: :collection
      end
      resources :players, only: [:index, :create, :show] do
        get :autocomplete_player_name, on: :collection
      end
      resources :matches, only: [:create]
    end
  end
end
