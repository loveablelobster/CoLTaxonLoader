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
end
