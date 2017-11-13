require 'mysql2'
require 'sequel'
require 'singleton'
#
module TaxonLoader
  #
  class Database
    include Singleton

    def connect(host, dbuser, database, password)
      @db = Sequel.connect(adapter: 'mysql2',
                    host: host,
                    database: database,
                    user: dbuser,
                    password: password)

      require_relative 'specify'
    end
  end

  #
  class Target
    attr_reader :agent, :taxonomy

    def initialize(config)
      Database.instance.connect(config[:host], config[:dbuser], config[:database], config[:password])

      discipline = Specify::Discipline[Name: config[:discipline]]
      @agent = Specify::Agent.first(division: discipline.division,
                                    user: Specify::User[Name: config[:specifyuser]]
                                   )
      @taxonomy = discipline.taxonomy
    end
  end
end
