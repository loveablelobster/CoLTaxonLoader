#
module TaxonLoader
  #
  class Target
    attr_reader :agent, :taxonomy

    def initialize(config)
      collection = Specify::Collection[CollectionName: config['collection']]
      @agent = Specify::Agent.where(division: collection.discipline.division,
                                    user: Specify::User[Name: config['spuser']]
                                   ).first
      @taxonomy = collection.discipline.taxonomy
    end
  end
end
