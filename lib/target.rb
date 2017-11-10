#
module TaxonLoader
  #
  class Target
    attr_reader :agent, :taxonomy

    def initialize(config)
      collection = Specify::Collection[CollectionName: config['collection']]
      @agent = Specify::Agent.first(division: collection.discipline.division,
                                    user: Specify::User[Name: config['spuser']]
                                   )
      @taxonomy = collection.discipline.taxonomy
    end
  end
end
