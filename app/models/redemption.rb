class Redemption < ApplicationRecord
  belongs_to :user, foreign_key: :user_rut, primary_key: :rut
  belongs_to :reward

  validates :redemption_code, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending used expired] }

  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: 'pending') }
  scope :used, -> { where(status: 'used') }

  before_validation :generate_redemption_code, on: :create
  before_validation :set_expiration, on: :create

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def mark_as_used!
    update!(status: 'used', used_at: Time.current)
  end

  def as_json_for_api
    {
      id: id,
      reward_name: reward.name,
      redeemed_at: created_at.iso8601,
      redemption_code: redemption_code,
      status: current_status,
      expires_at: expires_at&.iso8601
    }
  end

  private

  def current_status
    return 'expired' if expired? && status == 'pending'
    status
  end

  def generate_redemption_code
    self.redemption_code ||= SecureRandom.alphanumeric(6).upcase
  end

  def set_expiration
    self.expires_at ||= 30.days.from_now
  end
end
