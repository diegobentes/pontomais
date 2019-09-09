Rails.application.routes.draw do
  resources :vendas, :only => [:index, :create]
end
