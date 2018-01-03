module DeviseToken::Authenticable

    def authenticate_auth resource_class
      if token.present?
        DeviseToken::JsonWebToken.new(token: token).current_resource(resource_class)
      else
         resource_class.find_by(access_token: access_token)
      end
    end


    def token
      params[:auth_token] || auth_token_request
    end

    def access_token
      params[:access_token] || access_token_request
    end

    def access_token_request
      unless request.headers['access_token'].nil?
        request.headers.fetch("access_token")
      end
    end

    def auth_token_request
      unless request.headers['Authorization'].nil?
        request.headers.fetch("Authorization", "").split(" ").last
      end
    end



    def auth_token_response

    end

end
