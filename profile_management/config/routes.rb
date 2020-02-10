Rails.application.routes.draw do

  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create_user'
  get 'login', to: 'users#get_login'
  post 'login', to: 'users#post_login'
  get 'get_profile', to: 'users#get_user'

  get 'edit_user', to: 'users#edit_user'
  patch 'edit_user', to: 'users#update_user'


  get 'admins/show_panel'
  get 'admins/login'
  post 'admins/login' ,to: 'admins#post_login'
  get 'admins/logout'
  get 'admins/generate_report'
  get 'admins/search'
  get 'admins/get_user'

  get 'admins/create_user', to: 'admins#get_create_user'
  post 'admins/create_user', to: 'admins#post_create_user'

  get 'admins/edit_user', to: 'admins#edit_user'
  patch 'admins/edit_user', to: 'admins#update_user'
  get 'admins/deactivate_user'
  get 'admins/activate_user'

  #require 'sidekiq/web'
  #mount Sidekiq::Web => '/sidekiq'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
