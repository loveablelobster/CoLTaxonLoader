#
module Specify
  #
  class Collection < Sequel::Model(:collection)
    many_to_one :discipline, key: :DisciplineID
  end
end
