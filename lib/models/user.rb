#
module Specify
  #
  class User < Sequel::Model(:specifyuser)
    one_to_many :agents, key: :SpecifyUserID
  end
end
