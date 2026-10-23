class Word < ApplicationRecord
  belongs_to :category

  has_many :games,
           foreign_key: :secret_word_id,
           dependent: :restrict_with_error

  validates :word, presence: true,
                   uniqueness: { scope: :category_id }
end
