RedmineApp::Application.routes.draw do
  get 'help/search_syntax', to: 'elasticsearch#search_syntax'
end
