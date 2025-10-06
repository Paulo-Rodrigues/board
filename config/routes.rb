Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :frames, only: [ :create, :show, :destroy ] do
    post "circles", to: "frames/circles#create"
  end

  resources :circles, only: [ :index, :update, :destroy ]
end
