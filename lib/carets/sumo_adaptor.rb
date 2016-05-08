require 'faraday'

module Carets
  # This class gets the logs from Sumo for a given timeframe and search string
  class SumoAdaptor
    # TODO: Read this from a configuration file
    SUMOUSER = ''.freeze
    SUMOPASS = ''.freeze

    def initialize(time_start, increment)
      @time_start = time_start
      @time_end = time_start + increment
    end

    def get_logs(search_string)
      response = sumo_response(search_string)
      parse_response(response)
    end

    private

    def format_time(time)
      "#{time.to_date}T#{time.strftime('%H:%M:%S')}"
    end

    def parse_response(response)
      if response.nil?
        Rails.logger.error 'Sumo did not return any response.'
        []
      else
        if response.status.to_i != 200
          Rails.logger.error "Sumo returned the following non-200 status code: #{response.status}"
          []
        else
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError, TypeError
            Rails.logger.error "Cannot parse response body from sumo: #{response.body}"
            []
          end
        end
      end
    end

    def sumo_response(search_string)
      Rails.logger.info("Searching information for #{search_string} on #{@time_start}:#{@time_end}")
      sumo_api_connection.get do |req|
        req.params = { q: search_string, from: format_time(@time_start), to: format_time(@time_end) }
      end
    rescue ::Faraday::Error::ConnectionFailed, ::Faraday::Error::TimeoutError => e
      Rails.logger.error "Cannot connect to Sumo due to #{e.class}"
      raise
    end

    def sumo_api_connection
      Faraday.new(url: 'https://api.sumologic.com/api/v1/logs/search') do |faraday|
        faraday.request     :basic_auth, SUMOUSER, SUMOPASS
        faraday.adapter     Faraday.default_adapter # make requests with Net::HTTP
      end
    end
  end
end
