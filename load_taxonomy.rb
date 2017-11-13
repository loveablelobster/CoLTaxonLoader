usage = <<-EOF
Usage: load_taxonomy [DBCONFIG] [ROOTNAME] [ROOTRANK] [--] [arguments]

DBCONFIG: YAML file with the database connection

ROOTNAME: name of the taxon for which to search the api
ROOTRANK: root of the taxon for which to search the api

-h, --help:
  show help
-a, --adapter
  the adapter for the database connection (eg `mysql2` for MySQL or MariaDB)
-c, --connection
  MYSQLUSER@HOST
-d, --discipline
  the name of the discipline using the taxonomy
  into which the taxa are to be imported
-f, --configfile
  a config file in YAML format with the following structure:
  `adapter: ADAPTER`
  `host: HOSTNAME`
  `dbuser: MYSQLUSER`
  `password: DATABASEPASSWORD`
  `database: DATABASENAME`
  `specifyuser: SPECIFYUSERNAME`
  `discipline: DISCIPLINENAME`
  The explicit -f option is not necessary, as YAML files will be recognized
-p, --password
  the password for the MySQL connection
-s, --specify
  SPECIFYUSER@DATABASENAME
  the name of the specify database
  and the user account from which the taxa will be imported
  this is required for the CreatedBy and ModifiedBy attributes of every record
EOF

require 'getoptlong'
require 'io/console'
require 'psych'

config = {}

opts = GetoptLong.new(['--help', '-h', GetoptLong::NO_ARGUMENT],
                      ['--adapter', '-a', GetoptLong::REQUIRED_ARGUMENT],
                      ['--configfile', '-f', GetoptLong::REQUIRED_ARGUMENT],
                      ['--connection', '-c', GetoptLong::REQUIRED_ARGUMENT],
                      ['--discipline', '-d', GetoptLong::REQUIRED_ARGUMENT],
                      ['--password', '-p', GetoptLong::OPTIONAL_ARGUMENT],
                      ['--specify', '-s', GetoptLong::REQUIRED_ARGUMENT])

opts.each do |opt, arg|
  case opt
  when '--help'
    puts usage
  when '--adapter'
    config['adapter'] = arg
  when '--configfile'
    config = Psych.load_file(arg) # should merge with any paramas given
  when '--connection'
    config['dbuser'], config['host'] = *arg.split('@')
  when '--discipline'
    config['discipline'] = arg
  when '--password'
    config['password'] = arg unless arg.empty?
  when '--specify'
    config['specifyuser'], config['database'] = *arg.split('@')
  else
    puts 'invalid arguments'
    exit 0
  end
end

params = {}

rank_rx = /^(su(b|per)|infra|parva)?(phylum|class|order|family|genus|species)$/i

ARGV.each do |arg|
  case arg
  when rank_rx
    params[:rank] = arg
  when /.yml$/
    config = Psych.load_file(arg)
  else
    params[:name] = arg
  end
end

prompt = Proc.new do |text, secure = false|
  print text
  input = secure ? STDIN.noecho(&:gets).chomp : STDIN.gets.chomp
  puts if secure
  input
end

require_relative 'lib/stopwatch'
require_relative 'lib/target'
require_relative 'lib/taxon_loader'

config['host'] ||= prompt.call('Name of the host to connect to: ')
config['dbuser'] ||= prompt.call("Name of the MySQL user on #{config['host']}: ")
config['password'] ||= prompt.call("Password for #{config['dbuser']} on #{config['host']}: ", secure = true)
config['database'] ||= prompt.call('Name of the Specify database to use: ')
config['specifyuser'] ||= prompt.call('Name of the Specify user account from which the taxa will be imported: ')
config['discipline'] ||= prompt.call('Name of the discipline using the taxonomy into which to import: ')

target = TaxonLoader::Target.new(config)

loader = TaxonLoader::TaxonLoader.new(target, params[:name], params[:rank])

s = Stopwatch.new

loader.exhaustive_downstream_grab

puts s.elapsed_time
