Rails.application.routes.draw do
	get 'index' => "russellator#index"
	post 'search' => "russellator#search"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
