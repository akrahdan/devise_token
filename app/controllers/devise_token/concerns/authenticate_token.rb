module DeviseToken::Concerns::AuthenticateToken
  extend ActiveSupport::Concern
  include DeviseToken::Authenticable


  protected


  # user auth
  def authenticate_token(mapping=nil)
    # determine target authentication class
    rc = resource_class(mapping)
    @token = token

    return false unless @token
    # no default user defined
    return unless rc
    @resource =  authenticate_auth(rc)
    # user has already been found and authenticated
    return @resource if @resource && @resource.is_a?(rc)

  end

  def resource_class(m=nil)
    if m
      mapping = Devise.mappings[m]
    else
      mapping = Devise.mappings[resource_name] || Devise.mappings.values.first
    end

    mapping.to
  end

end
