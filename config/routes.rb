Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  resources :users, only:[] do
    resources :links
    resources :images do
      member do
        post :new_tag
        get :remove_tag
      end
      collection do
        post :plupload
      end
    end
  end

  resources :tags, only: [:index]
end
