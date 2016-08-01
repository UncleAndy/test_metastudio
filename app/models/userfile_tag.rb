class UserfileTag < ActiveRecord::Base
  belongs_to :userfile
  belongs_to :tag
end
