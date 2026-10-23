class Game < ApplicationRecord
  belongs_to :category
  belongs_to :secret_word, class_name: "Word", optional: true

  has_many :players, -> { order(:turn_order) }, dependent: :destroy

  validates :status, inclusion: { in: %w[setup playing completed] }
  validates :secret_word, presence: true, unless: -> { status == "setup" }

  validate :secret_word_matches_category

  private

  def secret_word_matches_category
    if secret_word && secret_word.category_id != category_id
      errors.add(:secret_word, "must belong to the selected category")
    end
  end
end
