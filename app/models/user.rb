class User < ApplicationRecord
  has_secure_password validations: false
  has_many :purchases, foreign_key: :user_rut, primary_key: :rut, dependent: :destroy
  has_many :redemptions, foreign_key: :user_rut, primary_key: :rut, dependent: :destroy
  has_many :notifications, foreign_key: :user_rut, primary_key: :rut, dependent: :destroy
  
  validates :rut, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2 }
  validates :address, length: { minimum: 5 }, allow_blank: true
  validates :phone, length: { in: 8..20 }, allow_blank: true
  
  validate :validate_rut_format
  validate :validate_region_if_chile
  
  before_validation :format_rut
  
  def self.find_by_credentials(rut: nil, email: nil)
    return nil if rut.blank? && email.blank?
    
    if rut.present?
      formatted_rut = format_rut_string(rut)
      find_by(rut: formatted_rut)
    elsif email.present?
      find_by(email: email.downcase.strip)
    end
  end

  # QR Token management
  def generate_qr_token!
    token = SecureRandom.urlsafe_base64(32)
    expires_at = 1.hour.from_now
    update!(qr_token: token, qr_token_expires_at: expires_at)
    { token: token, expires_at: expires_at }
  end

  def qr_token_valid?
    qr_token.present? && qr_token_expires_at.present? && qr_token_expires_at > Time.current
  end

  def self.find_by_qr_token(token)
    return nil if token.blank?
    user = find_by(qr_token: token)
    return nil unless user&.qr_token_valid?
    user
  end

  # Stamps management
  def add_stamps(count = 1)
    self.stamps = (stamps || 0) + count
  end

  def add_points(points)
    self.total_points = (total_points || 0) + points
  end

  def available_rewards_count
    stamps_paid - rewards_used
  end

  def current_stamps_progress
    purchases.count % 10
  end
  
  private
  
  def format_rut
    self.rut = self.class.format_rut_string(rut) if rut.present?
    self.email = email.downcase.strip if email.present?
  end
  
  def self.format_rut_string(rut)
    return nil if rut.blank?
    # Mantener el guion y el dígito verificador
    rut.to_s.strip.upcase
  end
  
  def validate_rut_format
    return if rut.blank?
    
    clean_rut = rut.gsub(/[^0-9kK]/, '')
    return errors.add(:rut, 'invalid format') if clean_rut.length < 2
    
    digits = clean_rut[0..-2]
    dv = clean_rut[-1].upcase
    
    return errors.add(:rut, 'invalid format') unless digits.match?(/^\d+$/)
    
    sum = 0
    mul = 2
    digits.reverse.each_char do |d|
      sum += d.to_i * mul
      mul = mul == 7 ? 2 : mul + 1
    end
    
    calculated_dv = 11 - (sum % 11)
    calculated_dv = calculated_dv == 11 ? '0' : (calculated_dv == 10 ? 'K' : calculated_dv.to_s)
    
    errors.add(:rut, 'invalid verification digit') unless dv == calculated_dv
  end
  
  def validate_region_if_chile
    if country == 'Chile' && region.blank?
      errors.add(:region, 'is required for Chile')
    end
  end
end
