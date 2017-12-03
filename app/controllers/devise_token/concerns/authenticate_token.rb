module DeviseToken::Concerns::AuthenticateToken
  extend ActiveSupport::Concern
  include DeviseToken::Controllers::Helpers
  include ::DeviseToken::Authenticable



  def get_case_insensitive_field_from_resource_params(field)
    # honor Devise configuration for case_insensitive keys
    q_value = resource_params[field.to_sym]

    if resource_class.case_insensitive_keys.include?(field.to_sym)
      q_value.downcase!
    end
    q_value
  end

  def find_resource(field, value)
    # fix for mysql default case insensitivity
    q = "#{field.to_s} = ? AND provider='#{provider.to_s}'"
    if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      q = "BINARY " + q
    end

    @resource = resource_class.where(q, value).first
  end

  def resource_class(m=nil)
    if m
      mapping = Devise.mappings[m]
    else
      mapping = Devise.mappings[resource_name] || Devise.mappings.values.first
    end

    mapping.to
  end

  def provider
    'email'
  end


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
