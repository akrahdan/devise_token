module DeviseToken
  class JsonWebToken

    attr_reader :token
    attr_reader :payload

    def initialize payload: {}, token: nil, verify_options: {}
      if token.present?
        @payload, _ = JWT.decode token.to_s, decode_key, true, options.merge(verify_options)
        @token = token
      else
        @payload = claims.merge(payload)
        @token = JWT.encode @payload,
          secret_key,
          DeviseToken.token_signature_algorithm
      end
    end

    def current_resource resource_class
      if resource_class.respond_to? :auth_payload
        resource_class.auth_payload @payload
      else
        resource_class.find @payload['sub']
      end
    end

    def to_json options = {}
      {jwt: @token}.to_json
    end


    private
     def secret_key
       DeviseToken.token_secret_signature_key.call
     end

     def decode_key
       DeviseToken.token_public_key || secret_key
     end

     def options
      verify_claims.merge({
        algorithm: DeviseToken.token_signature_algorithm
      })
    end

    def claims
      _claims = {}
      _claims[:exp] = token_lifetime if verify_lifetime?
      _claims[:aud] = token_audience if verify_audience?
      _claims
    end

    def token_lifetime
      DeviseToken.token_lifespan.from_now.to_i if verify_lifetime?
    end

    def verify_lifetime?
      !DeviseToken.token_lifespan.nil?
    end

    def verify_claims
      {
        aud: token_audience,
        verify_aud: verify_audience?,
        verify_expiration: verify_lifetime?
      }
    end

    def token_audience
      verify_audience? && DeviseToken.token_audience.call
    end

    def verify_audience?
      DeviseToken.token_audience.present?
    end

  end
end
