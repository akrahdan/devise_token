module DeviseToken::Concerns::AuthenticateToken
  include DeviseToken::Concerns::ResourceFinder
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




end
