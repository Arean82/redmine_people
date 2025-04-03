# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :people do
  collection do
    get :bulk_edit, :context_menu, :edit_mails, :preview_email
    post :bulk_edit, :bulk_update, :send_mails
    delete :bulk_destroy
  end
end

resources :departments do
  member do
    get :autocomplete_for_person
    post :add_people
    delete :remove_person
  end
end

resources :people_settings, only: [:index, :update, :destroy] do
  collection do
    get :autocomplete_for_user
  end
end

# API Routes (Versioned)
namespace :api do
  namespace :v1 do
    resources :people, only: [:index, :show, :create, :update, :destroy]
    resources :departments, only: [:index, :show, :create, :update, :destroy]
    resources :people_settings, only: [:index, :update]

    post 'people/:id/send_mail', to: 'people#send_mail'
    get 'departments/:id/people', to: 'departments#people'
  end
end
