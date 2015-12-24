$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your wagon's version:
require 'hitobito_pro_natura/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'hitobito_pro_natura'
  s.version     = HitobitoProNatura::VERSION
  s.authors     = ['Pascal Simon', 'Pascal Zumkehr']
  s.email       = ['hitobito-pro-natura@puzzle.ch']
  s.summary     = 'Wagon with Pro Natura specific groups'
  s.description = 'Wagon with Pro Natura specific groups'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'hitobito_youth'
end
