module DeviseToken
  class ConfirmationsController < DeviseToken::ApplicationController
    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource && @resource.id

        sign_in(@resource)
        @resource.save!

        yield @resource if block_given?

      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
