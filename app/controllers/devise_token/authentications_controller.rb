module DeviseToken
  class AuthenticationsController < DeviseToken::ApplicationController

    def new
      render_new_error
    end

    def create
      # Check
      field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

      @resource = nil
      if field
        q_value = get_case_insensitive_field_from_resource_params(field)

        @resource = find_resource(field, q_value)
      end

      if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        valid_password = @resource.valid_password?(resource_params[:password])
        if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
          render_create_error_bad_credentials
          return
        end

        @resource.save

        sign_in(:user, @resource, store: false, bypass: false)

        yield @resource if block_given?

        render_create_success

      elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        render_create_error_not_confirmed
      else
        render_create_error_bad_credentials
      end
    end



    protected

    def valid_params?(key, val)
      resource_params[:password] && key && val
    end


    def render_new_error
      render_error(405, I18n.t("devise_token.sessions.not_supported"))
    end

    def render_create_success
      render json: {
        status: 'success',
        header: auth_token,
        data: resource_data
      }
    end

    def render_create_error_not_confirmed
      render_error(401, I18n.t("devise_token.sessions.not_confirmed", email: @resource.email))
    end

    def render_create_error_bad_credentials
      render_error(401, I18n.t("devise_token.sessions.bad_credentials"))
    end

    def render_destroy_success
      render json: {
        success:true
      }, status: 200
    end

    def render_destroy_error
      render_error(404, I18n.t("devise_token.sessions.user_not_found"))
    end

    private

    def resource_params
      params.permit(*params_for_resource(:sign_in))
    end

  end
end
