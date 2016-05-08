require_relative '../carets/tracing_processor'

namespace :carets do
  desc 'process tracing logs will start an infinite loop to process logs of tracing information'
  task process_tracing_logs: :environment do
    loop do
      Rails.logger.info('Starting the infinite loop to process tracing logs')
      processing_slot = ProcessingSlot.reserve_next
      if processing_slot
        ProcessLogJob.perform_later(processing_slot, TracingProcessor.new)
      end
      sleep(10)
    end
  end

  desc 'Reprocess the last slot. Task used mainly for adhocing.'
  task process_one_trace_log: :environment do
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.info('Processing one slot')
    processing_slot = ProcessingSlot.last || ProcessingSlot.create!(slot_time: ProcessingSlot::CLOSEST_SLOT_TIME.ago)
    Rails.logger.info("Slot time: #{processing_slot.slot_time}")
    if processing_slot
      Carets::ProcessLogJob.perform_later(processing_slot, 'Carets::TracingProcessor')
    end
  end
end
