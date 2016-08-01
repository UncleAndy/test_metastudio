Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  resources :users, only:[] do
    resources :userfiles do
      collection do
        post :plupload
      end
      member do
        get :preview
        get :download
      end
    end
  end

  resources :tags, only: [:index]
end
