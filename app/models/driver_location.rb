class DriverLocation < ApplicationRecord
  belongs_to :driver

  validates :latitude, presence: true
  validates :longitude, presence: true
end
