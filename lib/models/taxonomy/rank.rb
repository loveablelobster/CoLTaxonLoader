#
module Specify
  #
  class Rank < Sequel::Model(:taxontreedefitem)
    many_to_one :taxonomy, key: :TaxonTreeDefID
    one_to_many :taxa, key: :TaxonTreeDefItemID
  end
end
