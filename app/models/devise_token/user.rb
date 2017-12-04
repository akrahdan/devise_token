
module DeviseToken::Concerns::User
  extend ActiveSupport::Concern

  included do
    # Hack to check if devise is already enabled
    unless self.method_defined?(:devise_modules)
      devise :database_authenticatable, :registerable,
          :recoverable, :trackable, :validatable, :confirmable
    end

    # don't use default devise email validation
    def email_required?
      false
    end

    def email_changed?
      false
    end

    def will_save_change_to_email?
      false
    end

    def password_required?
      return false unless provider == 'email'
      super
    end

    # override devise method to include additional info as opts hash
    def send_confirmation_instructions(opts=nil)
      unless @raw_confirmation_token
        generate_confirmation_token!
      end

      opts ||= {}

      if pending_reconfirmation?
        opts[:to] = unconfirmed_email
      end
      opts[:redirect_url] ||= DeviseToken.default_confirm_success_url

      send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
    end

    # override devise method to include additional info as opts hash
    def send_reset_password_instructions(opts=nil)
      token = set_reset_password_token

      opts ||= {}
      send_devise_notification(:reset_password_instructions, token, opts)

      token
    end

    # override devise method to include additional info as opts hash
    def send_unlock_instructions(opts=nil)
      raw, enc = Devise.token_generator.generate(self.class, :unlock_token)
      self.unlock_token = enc
      save(validate: false)

      opts ||= {}

      send_devise_notification(:unlock_instructions, raw, opts)
      raw
    end
  end

  module ClassMethods
    protected

    def database_exists?
      ActiveRecord::Base.connection_pool.with_connection { |con| con.active? } rescue false
    end
  end



  # this must be done from the controller so that additional params
  # can be passed on from the client
  def send_confirmation_notification?
    false
  end



  def confirmed?
    self.devise_modules.exclude?(:confirmable) || super
  end


  def token_lifespan
    DeviseToken.token_lifespan
  end



end
