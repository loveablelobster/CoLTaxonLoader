Sequel.inflections do |inflect|
  inflect.irregular 'taxon', 'taxa'
end

require_relative 'models/agent'
require_relative 'models/collection'
require_relative 'models/discipline'
require_relative 'models/division'
require_relative 'models/taxonomy/common_name'
require_relative 'models/taxonomy/rank'
require_relative 'models/taxonomy/taxonomy'
require_relative 'models/taxonomy/taxon'
require_relative 'models/user'
