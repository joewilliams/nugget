module Nugget
  class NStatsd # NStatsd since Statsd collides

    def self.stats
      @stats ||= Statsd.new(Nugget::Config.statsd_host, Nugget::Config.statsd_port, Nugget::Config.statsd_key).tap do |statsd|
        statsd.namespace =  Nugget::Config.statsd_namespace
      end
    end

    def self.send_metrics(name, result, response)
      statsd = Nugget::NStatsd.stats
      send_test_result(statsd, name, result)
      send_test_timings(statsd, name, response)
    end

    def self.send_test_result(statsd, name, result)

      if result == "FAIL"
        statsd.gauge("#{name}.failures.count", 1)
        Nugget::Log.debug("Sending the following to statsd: #{name}_failure_count: 1")
      else
        statsd.gauge("#{name}.failures.count", 0)
        Nugget::Log.debug("Sending the following to statsd: #{name}_failure_count: 0")
      end

    end

    def self.send_test_timings(statsd, name, response)
      if response      
        if response == "timeout"
	  Nugget::Log.debug("Sending the following to statsd: timeout: #{TIMEOUT}")
          statsd.timing("#{name}.timeout", TIMEOUT)
        else
          response.each do |key, value|
            if key.to_s.include?("_time")
              Nugget::Log.debug("Sending the following to statsd: #{key}: #{value}")
              statsd.timing("#{name}.#{key}", value)
            end
          end
        end
      end
    end

  end
end
