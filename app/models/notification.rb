class Notification < ApplicationRecord
  belongs_to :user, foreign_key: :user_rut, primary_key: :rut

  TYPES = %w[reward_available new_stamp promo].freeze

  validates :notification_type, presence: true, inclusion: { in: TYPES }
  validates :title, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(read: false) }
  scope :for_user, ->(rut) { where(user_rut: rut) }

  def mark_as_read!
    update!(read: true)
  end

  def as_json_for_api
    {
      id: id,
      type: notification_type,
      title: title,
      message: message,
      read: read,
      created_at: created_at.iso8601
    }
  end

  # Factory methods for creating notifications
  class << self
    def create_reward_available(user, reward_name)
      create!(
        user_rut: user.rut,
        notification_type: 'reward_available',
        title: '¡Nueva recompensa disponible!',
        message: "Ya puedes canjear: #{reward_name}"
      )
    end

    def create_new_stamp(user)
      create!(
        user_rut: user.rut,
        notification_type: 'new_stamp',
        title: '¡Nueva estampilla!',
        message: 'Has ganado una nueva estampilla por tu compra'
      )
    end

    def create_promo(user, title, message)
      create!(
        user_rut: user.rut,
        notification_type: 'promo',
        title: title,
        message: message
      )
    end
  end
end
