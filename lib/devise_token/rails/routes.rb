module ActionDispatch::Routing
  class Mapper
    def devise_token_for(resource, opts)
      # ensure objects exist to simplify attr checks
      opts[:controllers] ||= {}
      opts[:skip]        ||= []

      # check for ctrl overrides, fall back to defaults
      authentications_ctrl   = opts[:controllers][:sessions] || "devise_token/authentications"
      registrations_ctrl     = opts[:controllers][:registrations] || "devise_token/registrations"
      confirmations_ctrl     = opts[:controllers][:confirmations] || "devise_token/confirmations"
      token_validations_ctrl = opts[:controllers][:token_validations] || "devise_token/token_validations"

      # define devise controller mappings
      controllers = {:sessions           => authentications_ctrl,
                     :registrations      => registrations_ctrl,
                     :confirmations      => confirmations_ctrl}

      opts[:skip].each{|item| controllers.delete(item)}

      devise_for resource.pluralize.underscore.gsub('/', '_').to_sym,
        :class_name  => resource,
        :module      => :devise,
        :path        => "#{opts[:at]}",
        :controllers => controllers,
        :skip        => opts[:skip]

      unnest_namespace do
        # get full url path as if it were namespaced
        full_path = "#{@scope[:path]}/#{opts[:at]}"

        # get namespace name
        namespace_name = @scope[:as]

        # clear scope so controller routes aren't namespaced
        @scope = ActionDispatch::Routing::Mapper::Scope.new(
          path:         "",
          shallow_path: "",
          constraints:  {},
          defaults:     {},
          options:      {},
          parent:       nil
        )

        mapping_name = resource.underscore.gsub('/', '_')
        mapping_name = "#{namespace_name}_#{mapping_name}" if namespace_name

        devise_scope mapping_name.to_sym do
          # path to verify token validity
          get "#{full_path}/validate_token", controller: "#{token_validations_ctrl}", action: "validate_token"


        end
      end
    end

    # this allows us to use namespaced paths without namespacing the routes
    def unnest_namespace
      current_scope = @scope.dup
      yield
    ensure
      @scope = current_scope
    end

  end
end
