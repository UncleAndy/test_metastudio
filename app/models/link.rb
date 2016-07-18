class Link < ActiveRecord::Base
  # user_id, name, url

  belongs_to :user

  default_scope { order('created_at DESC') }
end
