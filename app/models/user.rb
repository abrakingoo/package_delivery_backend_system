class User < ApplicationRecord
  has_secure_password

  before_validation :normalize_email

  validates :name, presence: true

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :password,
            presence: true,
            length: { minimum: 6 }

  validates :password_confirmation, presence: true
end

private

def normalize_email
  self.email = email.to_s.strip.downcase
end