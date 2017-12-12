module DeviseToken
  module Controllers
    module Helpers
      extend ActiveSupport::Concern

      module ClassMethods

        def log_process_action(payload)
          payload[:status] ||= 401 unless payload[:exception]
          super
        end
      end

      # Define authentication filters and accessor helpers based on mappings.
      # These filters should be used inside the controllers as before_actions,
      # so you can control the scope of the user who should be signed in to
      # access that specific controller/action.
      # Example:
      #
      #   Roles:
      #     User
      #     Admin
      #
      #   Generated methods:
      #     authenticate_user!                   # Signs user in or 401
      #     authenticate_admin!                  # Signs admin in or 401
      #     user_signed_in?                      # Checks whether there is a user signed in or not
      #     admin_signed_in?                     # Checks whether there is an admin signed in or not
      #     current_user                         # Current signed in user
      #     current_admin                        # Current signed in admin
      #     render_authenticate_error            # Render error unless user or admin is signed in
      #
      #   Use:
      #     before_action :authenticate_user!  # Tell devise to use :user map
      #     before_action :authenticate_admin! # Tell devise to use :admin map
      #
      def self.define_helpers(mapping) #:nodoc:
        mapping = mapping.name

        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def authenticate_#{mapping}_token!(opts={})
            unless current_#{mapping}
              render_authenticate_error
            end
          end

          def #{mapping}_signed_in?
            !!current_#{mapping}
          end

          def current_#{mapping}
            @current_#{mapping} ||= authenticate_token(:#{mapping})
          end


          def #{mapping}_session
            current_#{mapping} && warden.session(:#{mapping})
          end


          def render_authenticate_error
            return render json: {
              errors: [I18n.t('devise.failure.unauthenticated')]
            }, status: 401
          end
        METHODS

        ActiveSupport.on_load(:action_controller) do
          if respond_to?(:helper_method)
            helper_method "current_#{mapping}", "#{mapping}_signed_in?", "#{mapping}_session", "render_authenticate_error"
          end
        end
      end
    end
  end
end
