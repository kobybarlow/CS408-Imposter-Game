class Player < ApplicationRecord
  belongs_to :game

  validates :name, presence: true
  validates :is_imposter, inclusion: { in: [ true, false ] }

  validates :turn_order,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: :game_id }
end
