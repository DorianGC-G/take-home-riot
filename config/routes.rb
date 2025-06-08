Rails.application.routes.draw do
  post "/encrypt", to: "crypto#encrypt"
  post "/decrypt", to: "crypto#decrypt"
end
