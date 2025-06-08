Rails.application.routes.draw do
  post "/encrypt", to: "crypto#encrypt"
  post "/decrypt", to: "crypto#decrypt"
  post "/sign", to: "crypto#sign"
  post "/verify", to: "crypto#verify"
end
