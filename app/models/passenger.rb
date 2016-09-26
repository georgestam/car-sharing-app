class Passenger < ApplicationRecord
  belongs_to :user  # The passenger
  belongs_to :journey

  # remove
  belongs_to :passenger_location

  validates :user_id, uniqueness: { scope: :journey_id }

end
