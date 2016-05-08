module Carets
  # Processes logs containing tracing information
  class TracingProcessor
    def search_string
      'Tracing information'
    end

    def process(logs)
      Rails.logger.info("#{logs.size} logs with tracing information to parse")
      logs.each do
        # TODO: Send to Zipkin
      end
    end
  end
end
