require "devise_token/rails/routes"

module DeviseToken
  class Engine < ::Rails::Engine
    isolate_namespace DeviseToken

    initializer "devise_token.url_helpers" do
      Devise.helpers << DeviseToken::Controllers::Helpers
    end
  end

  mattr_accessor :change_headers_on_each_request,
                 :token_lifespan,
                 :default_confirm_success_url,
                 :default_password_reset_url,
                 :redirect_whitelist,
                 :check_current_password_before_update,
                 :enable_standard_devise_support,
                 :remove_tokens_after_password_reset,
                 :default_callbacks,
                 :token_secret_signature_key,
                 :token_signature_algorithm

  self.change_headers_on_each_request       = true
  self.token_lifespan                       = 2.weeks
  self.default_confirm_success_url          = nil
  self.default_password_reset_url           = nil
  self.redirect_whitelist                   = nil
  self.check_current_password_before_update = false
  self.enable_standard_devise_support       = false
  self.remove_tokens_after_password_reset   = false
  self.default_callbacks                    = true
  self.token_secret_signature_key           = -> { Rails.application.secrets.secret_key_base }
  self.token_signature_algorithm            = 'HS256'


  def self.setup(&block)
    yield self
  end
end
