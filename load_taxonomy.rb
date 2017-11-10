usage = <<-EOF
Usage: load_taxonomy [DBCONFIG] [ROOTNAME] [ROOTRANK] [--] [arguments]

DBCONFIG: YAML file with the database connection

ROOTNAME: name of the taxon for which to search the api
ROOTRANK: root of the taxon for which to search the api

-h, --help:
  show help
-d, --discipline
  the name of the discipline using the taxonomy to which the taxa are to be imported
-s, --specifyuser
  the name of the specify user account from which the taxa will be imported
  this is required for the CreatedBy and ModifiedBy attributes of every record
EOF

require 'getoptlong'
require 'io/console'

discipline, specifyuser = nil

opts = GetoptLong.new(['--help', '-h', GetoptLong::NO_ARGUMENT],
                      ['--discipline', '-d', GetoptLong::REQUIRED_ARGUMENT],
                      ['--specifyuser', '-s', GetoptLong::REQUIRED_ARGUMENT])
                 .each do |opt, arg|
  case opt
  when '--help'
    puts usage
  when '--discipline'
    discipline = arg
  when '--specifyuser'
    specifyuser = arg
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

config = Psych.load_file(params[:config])

DB = Sequel.connect(adapter: config['adapter'],
                    host: config['host'],
                    database: config['database'],
                    user: config['user'],
                    password: config['password'])

prompt = Proc.new do |text|
  print text
  STDIN.gets.chomp
end
# unless password
#   print "password for #{dbuser}@#{host}: "
#   password = STDIN.noecho(&:gets).chomp
#   puts
# end

require_relative 'lib/specify'
require_relative 'lib/stopwatch'
require_relative 'lib/target'
require_relative 'lib/taxon_loader'

d = discipline || prompt.call('Name of the discipline using the taxonomy into which to import: ')
s = specifyuser || prompt.call('Name of the specify user account from which the taxa will be imported: ')

target = TaxonLoader::Target.new(config, d, s)

loader = TaxonLoader::TaxonLoader.new(target, params[:name], params[:rank])

s = Stopwatch.new

# root = loader.service.full_record_for(name: params[:name], rank: params[:rank]).first

loader.exhaustive_downstream_grab

puts s.elapsed_time


