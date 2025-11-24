class User < ApplicationRecord
  has_secure_password validations: false
  has_many :purchases, foreign_key: :user_rut, primary_key: :rut, dependent: :destroy
  
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
