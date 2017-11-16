#
module TaxonLoader
  #
  class Database
    include Singleton

    def connect(config)
      @db = Sequel.connect(adapter: 'mysql2',
                           host: config[:host],
                           database: config[:database],
                           user: config[:dbuser],
                           password: config[:password])
      require_relative 'specify'
    end
  end
end
