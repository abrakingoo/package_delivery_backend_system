class Driver < ApplicationRecord
  has_secure_password
  has_one :driver_location


  before_validation :normalize_email
  reverse_geocoded_by :latitude, :longitude

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
