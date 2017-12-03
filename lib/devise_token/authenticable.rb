module DeviseToken
  class Authenticable

    def authenticate_auth resource_class
      if token
        DeviseToken.JsonWebToken.new(token: token).current_resource(resource_class)
      end
    end

    def token
      params[:auth_token] || auth_token_request
    end

    def auth_token_request
      unless request.headers['Authorization'].nil?
        request.headers.fetch("Authorization", "").split(" ").last
      end
    end

    def auth_token_response

    end


  end
end
