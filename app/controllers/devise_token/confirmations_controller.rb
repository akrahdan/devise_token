module DeviseToken
  class ConfirmationsController < DeviseToken::ApplicationController
    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource && @resource.id

        sign_in(@resource)
        @resource.save!

        yield @resource if block_given?

        redirect_header_options = {account_confirmation_success: true}
        redirect_headers = build_redirect_headers(token,
                                                  client_id,
                                                  redirect_header_options)
        redirect_to(@resource.build_auth_url(params[:redirect_url],
                                             redirect_headers))
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
