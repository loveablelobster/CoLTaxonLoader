#
module Specify
  #
  class Taxonomy < Sequel::Model(:taxontreedef)
    one_to_many :disciplines, key: :TaxonTreeDefID
    one_to_many :ranks, key: :TaxonTreeDefID
    one_to_many :taxa, key: :TaxonTreeDefID

    def rank(rank_name)
      ranks_dataset.where(Name: rank_name.capitalize).first
    end

#     def root_taxon
#     end
  end
end
