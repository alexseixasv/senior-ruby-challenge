Rails.application.routes.draw do
  get "/up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    get "dashboard/summary", to: "dashboard#summary"
    resources :invoices, only: %i[index show create update]

    resources :documents, only: [:show] do
      member do
        post :process, action: :enqueue
      end
    end

    namespace :webhooks do
      post "payments", to: "payments#create"
    end
  end
end
