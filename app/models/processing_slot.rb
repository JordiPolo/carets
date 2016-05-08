# Processing slots are awarded when it is time to do some processing
# We use permanent storage so we know when the last happened even if we have several machines
# processing or there is an interruption in the service
# status
# slot_time
class ProcessingSlot < ActiveRecord::Base
  # TODO: Make all these constants configurable.

  # Time we wait till we start processing any data
  # We will not return a slot that is closer than this value.
  CLOSEST_SLOT_TIME = 10.minutes.freeze

  # Maximum time we wait till we start processing data.
  # For instance, the first time we deploy
  # Or if our processing engine is too slow to keep up with data, we will be
  # getting slots from around this time instead of from CLOSEST_SLOT_TIME
  FARTHEST_SLOT_TIME = 1.hour.freeze

  # How much time we will process per slot
  SLOT_TIME = 24.seconds.freeze

  # How big is the window we say we are processing
  # if SLOT_WINDOW == SLOT_TIME then we are trying to process all the data
  # if SLOT_WINDOW is double SLOT_TIME we will process half of the data and skip the other half
  SLOT_WINDOW = SLOT_TIME * 10 # Only process 10% of the time

  STATUSES = %w(created, processing, done).freeze

  validates :slot_time, uniqueness: true

  # validates :status, inclusion: { in: STATUSES }

  after_create :set_status_created

  def self.reserve_next
    # TODO: Deal with concurrency issues
    # If there are different processes trying to get a slot, we may get the same one twice
    # It may not be a big issue depending on the application
    last_processed_time = ProcessingSlot.last.try(:slot_time) || 1.year.ago
    time_now = Time.now

    # Too early to give any new slot
    return false unless time_now > last_processed_time + CLOSEST_SLOT_TIME + SLOT_WINDOW

    # Ooops, we are over the maximum allowed range of time
    if time_now > last_processed_time + FARTHEST_SLOT_TIME
      ProcessingSlot.create(slot_time: time_now - FARTHEST_SLOT_TIME + SLOT_WINDOW)
    # Between closest and farthest, where we want to be
    else
      ProcessingSlot.create(slot_time: last_processed_time + SLOT_WINDOW)
    end
  end

  private

  def set_status_created
    self.status = 'created'
  end
end
