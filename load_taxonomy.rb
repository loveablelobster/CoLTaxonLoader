usage = <<-EOF
Usage: load_taxonomy [DBCONFIG] [ROOTNAME] [ROOTRANK] [--] [arguments]

DBCONFIG: YAML file with the database connection

ROOTNAME: name of the taxon for which to search the api
ROOTRANK: root of the taxon for which to search the api

-h, --help:
  show help

EOF

require 'getoptlong'

opts = GetoptLong.new(['--help', '-h', GetoptLong::NO_ARGUMENT]).each do |opt, arg|
  case opt
  when '--help'
    puts usage
  else
    puts 'invalid arguments'
    exit 0
  end
end

require 'mysql2'
require 'psych'
require 'sequel'

params = {}

rank_rx = /^(su(b|per)|infra|parva)?(phylum|class|order|family|genus|species)$/i

ARGV.each do |arg|
  case arg
  when rank_rx
    params[:rank] = arg
  when /.yml$/
    params[:config] = arg
  else
    params[:name] = arg
  end
end

p params

config = Psych.load_file(params[:config])

DB = Sequel.connect(adapter: config['adapter'],
                    host: config['host'],
                    database: config['database'],
                    user: config['user'],
                    password: config['password'])

require_relative 'lib/catalogue_of_life'
require_relative 'lib/specify'
require_relative 'lib/stopwatch'
require_relative 'lib/target'
require_relative 'lib/taxon_loader'

target = TaxonLoader::Target.new(config)
loader = TaxonLoader::TaxonLoader.new(target, params[:name], params[:rank])

s = Stopwatch.new

# root = loader.service.full_record_for(name: params[:name], rank: params[:rank]).first

loader.exhaustive_downstream_grab

puts s.elapsed_time


