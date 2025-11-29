class Reward < ApplicationRecord
  has_many :redemptions, dependent: :destroy

  validates :name, presence: true
  validates :stamps_required, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(stamps_required: :asc) }

  def as_json_for_api
    {
      id: id,
      name: name,
      description: description,
      stamps_required: stamps_required,
      image_url: image_url
    }.compact
  end
end
