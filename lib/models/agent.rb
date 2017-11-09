#
module Specify
  #
  class Agent < Sequel::Model(:agent)
    many_to_one :user, key: :SpecifyUserID
    many_to_one :division, key: :DivisionID
  end
end
