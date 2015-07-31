Rails.application.routes.draw do
  root 'home#leaderboard'

  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      resources :players, only: [:index, :show] do
      end
    end
  end
end
