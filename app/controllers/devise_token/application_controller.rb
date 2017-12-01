module DeviseToken
  class ApplicationController < DeviseController

    before_action :set_default_format
    before_action :authenticate_token!

    attri_reader :current_user

    def resource_data(opts={})
      response_data = opts[:resource_json] || @resource.as_json
      if json_api?
        response_data['type'] = @resource.class.name.parameterize
      end
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

      def authenticate_token!
        payload = JsonWebToken.decode(auth_token)
        @current_user = User.find(payload["sub"])
      rescue JWT::ExpiredSignature
        render json: { errors: ["Auth token has expired"]}, status: :unauthorized
      end
      rescue JWT::DecodeError
        render json: { errors: ["Invalid auth token"]}, status: :unauthorized
      end

      def auth_token
        @auth_token = request.headers.fetch("Authorization", "").split(" ").last
      end

  end
end
