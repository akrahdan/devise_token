$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "devise_token/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "devise_token"
  s.version     = DeviseToken::VERSION
  s.authors     = ["Samuel Akrah"]
  s.email       = ["akrahdan@gmail.com"]
  s.summary       = "JWT Token based authentication with devise. "
  s.description   = "Authentication for all Rails Api applications"
  s.homepage      = "https://github.com/akrahdan/devise_token"
  s.license       = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_runtime_dependency 'rails', '~> 5.1', '>= 5.1.4'
  s.add_dependency "devise", "> 3.5.2", "< 4.4"
  s.add_dependency "jwt", "~> 2.1"
  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency 'pg'
  s.add_development_dependency 'mysql2'
end
