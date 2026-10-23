class Category < ApplicationRecord
  has_many :games, dependent: :restrict_with_error
  has_many :words, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
