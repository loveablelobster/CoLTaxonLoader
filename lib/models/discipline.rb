#
module Specify
  #
  class Discipline < Sequel::Model(:discipline)
    many_to_one :division, key: :DivisionID
    many_to_one :taxonomy, key: :TaxonTreeDefID
  end
end
