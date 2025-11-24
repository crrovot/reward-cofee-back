class Purchase < ApplicationRecord
  belongs_to :user, foreign_key: :user_rut, primary_key: :rut
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :user_rut, presence: true
  
  before_create :calculate_points
  after_create :update_user_stats
  
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(rut) { where(user_rut: rut) }
  
  private
  
  def calculate_points
    self.points_earned = (amount / 100).floor
  end
  
  def update_user_stats
    user.reload
    total_purchases = user.purchases.count
    total_points = user.purchases.sum(:points_earned)
    stamps = total_purchases / 10
    
    user.update_columns(
      total_points: total_points,
      stamps_paid: stamps
    )
  end
end
