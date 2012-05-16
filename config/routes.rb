Diarrhea::Application.routes.draw do
  root :to => 'dashboard#index'

  resources :projects do
    member do
      get 'init'
      get 'pull'
      get 'run'
      get 'ajaxupdate'
    end
  end

  resources :nodes do
    resources :commands
    member do
      get 'ping'
      get 'clear'
      get 'prepare'
      get 'ajaxupdate'
    end
    collection do
      get 'prepare'
      get 'resetdb'
      get 'alive'
      get 'dead'
      get 'locked'
      get 'prepare_all'
      get 'updatedb_all'
      get 'bundle'
    end
  end

  resources :runs do
    member do
      get 'run'
      get 'ajaxupdate'
    end
    collection do
      get 'stop'
    end
  end


  resources :scenarios do
    member do
      get 'rerun'
      get 'ajaxupdate'
    end
  end

  resources :feature_files do
    resources :scenarios
    member do
      get 'ajaxupdate'
    end
  end

  resources :commands
  # match ':controller(/:action(/:id(.:format)))'
end
