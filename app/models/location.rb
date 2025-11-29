class Location < ApplicationRecord
  has_many :purchases, dependent: :nullify

  validates :name, presence: true
  validates :address, presence: true

  scope :active, -> { where(active: true) }

  def as_json_for_api
    {
      id: id,
      name: name,
      address: address,
      phone: phone,
      hours: hours,
      latitude: latitude&.to_f,
      longitude: longitude&.to_f
    }.compact
  end
end
