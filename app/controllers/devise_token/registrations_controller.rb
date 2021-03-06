module DeviseToken
  class RegistrationsController < DeviseToken::ApplicationController
    before_action :validate_sign_up_params, :only => :create
    before_action :validate_account_update_params, :only => :update

   def create
     @resource            = resource_class.new(sign_up_params.except(:confirm_success_url))
     @resource.provider   = provider


     if resource_class.case_insensitive_keys.include?(:email)
       @resource.email = sign_up_params[:email].try :downcase
     else
       @resource.email = sign_up_params[:email]
     end


     @redirect_url = sign_up_params[:confirm_success_url]


     @redirect_url ||= DeviseToken.default_confirm_success_url


     if confirmable_enabled? && !@redirect_url
       return render_create_error_missing_confirm_success_url
     end


     if DeviseToken.redirect_whitelist
       unless DeviseToken::Url.whitelisted?(@redirect_url)
         return render_create_error_redirect_url_not_allowed
       end
     end

     begin
       # override email confirmation, must be sent manually from ctrl
       resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
       resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
       if @resource.respond_to? :skip_confirmation_notification!
         # Fix duplicate e-mails by disabling Devise confirmation e-mail
         @resource.skip_confirmation_notification!
       end
       if @resource.save
         yield @resource if block_given?

         unless @resource.confirmed?
           # user will require email authentication
           @resource.send_confirmation_instructions({
             redirect_url: @redirect_url
           })

         else

           @resource.save!


         end
         render_create_success
       else
         clean_up_passwords @resource
         render_create_error
       end
     rescue ActiveRecord::RecordNotUnique
       clean_up_passwords @resource
       render_create_error_email_already_exists
     end
   end


   def destroy
     if @resource
       @resource.destroy
       yield @resource if block_given?

       render_destroy_success
     else
       render_destroy_error
     end
   end

   def sign_up_params
     params.permit([*params_for_resource(:sign_up), :confirm_success_url])
   end

   def account_update_params
     params.permit(*params_for_resource(:account_update))
   end

   protected

     def render_create_error_missing_confirm_success_url
       response = {
         status: 'error',
         data:   resource_data
       }
       message = I18n.t("devise_token.registrations.missing_confirm_success_url")
       render_error(422, message, response)
     end

     def render_create_error_redirect_url_not_allowed
       response = {
         status: 'error',
         data:   resource_data
       }
       message = I18n.t("devise_token.registrations.redirect_url_not_allowed", redirect_url: @redirect_url)
       render_error(422, message, response)
     end

     def render_create_success
       render json: {
         status: 'success',
         header: auth_token,
         data:   resource_data
       }
     end

     def render_create_error
       render json: {
         status: 'error',
         data:   resource_data,
         errors: resource_errors
       }, status: 422
     end

     def render_create_error_email_already_exists
       response = {
         status: 'error',
         data:   resource_data
       }
       message = I18n.t("devise_token.registrations.email_already_exists", email: @resource.email)
       render_error(422, message, response)
     end

     def render_update_success
       render json: {
         status: 'success',
         data:   resource_data
       }
     end

     def render_update_error
       render json: {
         status: 'error',
         errors: resource_errors
       }, status: 422
     end

     def render_update_error_user_not_found
       render_error(404, I18n.t("devise_token.registrations.user_not_found"), { status: 'error' })
     end

     def render_destroy_success
       render json: {
         status: 'success',
         message: I18n.t("devise_token.registrations.account_with_uid_destroyed", uid: @resource.uid)
       }
     end

     def render_destroy_error
       render_error(404, I18n.t("devise_token.registrations.account_to_destroy_not_found"), { status: 'error' })
     end

    private

     def resource_update_method
       if DeviseToken.check_current_password_before_update == :attributes
         "update_with_password"
       elsif DeviseToken.check_current_password_before_update == :password && account_update_params.has_key?(:password)
         "update_with_password"
       elsif account_update_params.has_key?(:current_password)
         "update_with_password"
       else
         "update_attributes"
       end
     end

     def validate_sign_up_params
       validate_post_data sign_up_params, I18n.t("errors.messages.validate_sign_up_params")
     end

     def validate_account_update_params
       validate_post_data account_update_params, I18n.t("errors.messages.validate_account_update_params")
     end

     def validate_post_data which, message
       render_error(:unprocessable_entity, message, { status: 'error' }) if which.empty?
     end
  end
end
