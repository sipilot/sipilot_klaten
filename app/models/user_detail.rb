class UserDetail < ApplicationRecord
  belongs_to :user

  has_one_attached :profile_photo
end
