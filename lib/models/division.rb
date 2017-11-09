#
module Specify
  #
  class Division < Sequel::Model(:division)
    one_to_many :disciplines, key: :DivisionID
  end
end
