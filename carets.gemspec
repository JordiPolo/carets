$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'carets/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'carets'
  s.version     = Carets::VERSION
  s.authors     = ['Jordi Polo']
  s.email       = ['mumismo@gmail.com']
  s.homepage    = 'TODO'
  s.summary     = 'TODO: Summary of Carets.'
  s.description = 'TODO: Description of Carets.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4.2.6'
  s.add_dependency 'faraday'

  s.add_development_dependency 'sqlite3'
end
