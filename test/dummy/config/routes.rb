Rails.application.routes.draw do
  mount DeviseToken::Engine => "/devise_token"
end
