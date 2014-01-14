module Nugget
  class Backstop

    def self.send_metrics(name, result, response)
      send_test_result(name, result)
      send_test_timings(name, response)
    end

    def self.send_test_result(name, result)

      pass_fail = 0

      if result == "FAIL"
        pass_fail = 1
      end

      backstop_requst("#{name}.result", pass_fail)
    end

    def self.send_test_timings(name, response)

      response.each do |key, value|
        if key.to_s.include?("_time")
          backstop_requst("#{name}.#{key}", value)
        end
      end

    end

    def self.backstop_requst(metric, value)

      Nugget::Log.debug("Sending the following to backstop: #{metric}: #{value}")

      body = [{
        metric: metric,
        value: value,
        measure_time: Time.now.to_i
      }].to_json

      request = Typhoeus::Request.new(
        Nugget::Config.backstop_url,
        method: :post,
        body: body,
        headers: { 'Content-Type' => 'application/json' }
      )

      response = request.run

      if response.options[:response_code] > 299
        # hack a bad response error in here
        Nugget::Log.error("Error publishing #{metric} to backstop, got #{response.options[:response_code]}")
      end

    end

  end
end