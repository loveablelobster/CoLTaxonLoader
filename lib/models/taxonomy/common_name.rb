#
module Specify
  #
  class CommonName < Sequel::Model(:commonnametx)
    many_to_one :taxon, key: :TaxonID
  end
end
