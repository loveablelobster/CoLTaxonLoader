require 'getoptlong'
require 'io/console'
require 'psych'
require_relative 'lib/target'
require_relative 'lib/taxon_loader'
require_relative 'lib/stopwatch'

conf_file = nil
config = {}
include_extinct = false

opts = GetoptLong.new(['--help', '-h', GetoptLong::NO_ARGUMENT],
                      ['--adapter', '-a', GetoptLong::REQUIRED_ARGUMENT],
                      ['--configfile', '-f', GetoptLong::REQUIRED_ARGUMENT],
                      ['--connection', '-c', GetoptLong::REQUIRED_ARGUMENT],
                      ['--discipline', '-d', GetoptLong::REQUIRED_ARGUMENT],
                      ['--extinct', '-e', GetoptLong::NO_ARGUMENT],
                      ['--password', '-p', GetoptLong::OPTIONAL_ARGUMENT],
                      ['--specify', '-s', GetoptLong::REQUIRED_ARGUMENT])

opts.each do |opt, arg|
  case opt
  when '--help'
    File.open('usage.txt', 'r').each { |line| puts line }
  when '--adapter'
    config[:adapter] = arg
  when '--configfile'
    conf_file = Psych.load_file(arg) # should merge with any paramas given
  when '--connection'
    config[:dbuser], config[:host] = *arg.split('@')
  when '--discipline'
    config[:discipline] = arg
  when '--password'
    config[:password] = arg unless arg.empty?
  when '--specify'
    config[:specifyuser], config[:database] = *arg.split('@')
  when '--extinct'
    include_extinct = true
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
    conf_file = Psych.load_file(arg)
  else
    params[:name] = arg
  end
end

exit 0 unless params[:name] # FIXME: issue warning if there is no rank

# merge config from file with any given command line args (args ovveride file)
conf_file&.each { |k, v| config[k.to_sym] ||= v }

# if still missing config items, prompt user
prompt = Proc.new do |text, secure = false|
  print text
  input = secure ? STDIN.noecho(&:gets).chomp : STDIN.gets.chomp
  puts if secure
  input
end

config[:host] ||= prompt.call('Name of the host to connect to: ')
config[:dbuser] ||= prompt.call("Name of the MySQL user on #{config[:host]}: ")
config[:password] ||= prompt.call("Password for #{config[:dbuser]} on #{config[:host]}: ", secure = true)
config[:database] ||= prompt.call('Name of the Specify database to use: ')
config[:specifyuser] ||= prompt.call('Name of the Specify user account from which the taxa will be imported: ')
config[:discipline] ||= prompt.call('Name of the discipline using the taxonomy into which to import: ')

target = TaxonLoader::Target.new(config)

loader = TaxonLoader::TaxonLoader.new(target, params[:name], params[:rank], include_extinct_taxa: include_extinct)

s = Stopwatch.new

loader.exhaustive_downstream_grab
puts '--------------------------------------------------------------------------------'
puts 'Number of newly inserted taxa:'
loader.ticker.new_taxon_count.each { |k, v| puts "#{k}: #{v}" if v >= 1 }
puts s.elapsed_time
