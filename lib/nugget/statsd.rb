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
        statsd.gauge("#{name}.result", 1)
      else
        statsd.gauge("#{name}.result", 0)
      end

    end

    def self.send_test_timings(statsd, name, response)

      response.each do |key, value|
        if key.to_s.include?("_time")
          stats.timing("#{name}.#{key}", value)
        end
      end

    end

  end
end