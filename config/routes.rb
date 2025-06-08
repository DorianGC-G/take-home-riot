Rails.application.routes.draw do
  post "/encrypt", to: "crypto#encrypt"
end
