#
module TaxonLoader
  #
  class Target
    attr_reader :agent, :taxonomy

    def initialize(config, discipline, specifyuser)
      discipline = Specify::Discipline[Name: discipline]
      @agent = Specify::Agent.first(division: discipline.division,
                                    user: Specify::User[Name: specifyuser]
                                   )
      @taxonomy = discipline.taxonomy
    end
  end
end
