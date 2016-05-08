require 'carets/sumo_adaptor'
module Carets
  # This is a general job which gets a processing slot and a processor.
  # It will search in sumo the information needed by the processor and
  # allow the processor to process that information.
  # This class should not need to change to acomodate different processing of logs
  class ProcessLogJob < ActiveJob::Base
    def perform(slot, processor_classname)
      Rails.logger.info("Processing logs #{slot.slot_time} to #{slot.slot_time + ProcessingSlot::SLOT_TIME}")
      slot.status = 'processing'
      slot.save!
      processor = processor_classname.classify.safe_constantize.new
      logs = SumoAdaptor.new(slot.slot_time, ProcessingSlot::SLOT_TIME).get_logs(processor.search_string)
      processor.process(logs)
      slot.status = 'done'
      slot.save!
      Rails.logger.info("Processed logs #{slot.slot_time} to #{slot.slot_time + ProcessingSlot::SLOT_TIME}")
    end

    # TODO: Access to the slot to mark it as failed
    rescue_from(NameError) do |exception|
      Rails.logger.error(%(Error in job #{self.class.name}, #{exception.class}: #{exception.message} #{exception.backtrace.join("\n")}))
    end
  end
end
