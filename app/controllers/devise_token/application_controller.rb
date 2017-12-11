module DeviseToken
  class ApplicationController < DeviseController
    protect_from_forgery with: :null_session
    include ::DeviseToken::Concerns::AuthenticateToken
    include DeviseToken::Concerns::ResourceFinder

    before_action :set_default_format


    def resource_data(opts={})
      response_data = opts[:resource_json] || @resource.as_json
      response_data
    end

    def resource_errors
      return @resource.errors.to_hash.merge(full_messages: @resource.errors.full_messages)
    end

    protected


      def params_for_resource(resource)
        devise_parameter_sanitizer.instance_values['permitted'][resource].each do |type|
          params[type.to_s] ||= request.headers[type.to_s] unless request.headers[type.to_s].nil?
        end
        devise_parameter_sanitizer.instance_values['permitted'][resource]
      end

      def resource_class(m=nil)
        if m
          mapping = Devise.mappings[m]
        else
          mapping = Devise.mappings[resource_name] || Devise.mappings.values.first
        end

        mapping.to
      end

      def recoverable_enabled?
        resource_class.devise_modules.include?(:recoverable)
      end

      def confirmable_enabled?
        resource_class.devise_modules.include?(:confirmable)
      end

      def render_error(status, message, data = nil)
        response = {
          success: false,
          errors: [message]
        }
        response = response.merge(data) if data
        render json: response, status: status
      end


      def set_default_format
        request.format = :json
      end

      def auth_token
       if resource.respond_to? :auth_response_token
         DeviseToken::JsonWebToken.new payload: resource.auth_response_token
       else
         DeviseToken::JsonWebToken.new payload: { sub: resource.id }
       end
      end

      def resource
       @resource ||=
         if resource_class.respond_to? :auth_request_payload
           resource_class.auth_request_payload request
         else
           resource_class.find_by email: resource_params[:email]
         end
      end

  end
end
