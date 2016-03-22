module Nugget
  class NStatsd # NStatsd since Statsd collides

    def self.stats
      @stats ||= Statsd.new(Nugget::Config.statsd_host, Nugget::Config.statsd_port, Nugget::Config.statsd_key).tap do |statsd|
        statsd.namespace =  Nugget::Config.statsd_namespace
      end
    end

    def self.send_metrics(name, result, response)
      statsd = Nugget::NStatsd.stats
      send_test_result(statsd, name, result, response)
      send_test_timings(statsd, name, result, response)
    end

    private

    def self.send_test_result(statsd, name, result, response)
      failure = (result == "FAIL")
      dns_failure = failure && response.is_a?(Hash) && response[:return_code] == :couldnt_resolve_host
      tcp_failure = failure && response.is_a?(Hash) && response[:return_code] == :couldnt_connect
      tls_failure = failure && response.is_a?(Hash) && response[:return_code] == :ssl_connect_error

      gauge("failures", failure)
      gauge("failures.dns", dns_failure)
      gauge("failures.tcp", tcp_failure)
      gauge("failures.tls", tls_failure)
    end

    def self.gauge(stat, count)
      metric = "#{name}.#{stat}.count"
      statsd.gauge(metric, count)
      Nugget::Log.debug("Sending the following to statsd: #{metric}: #{count}")
    end

    def self.send_test_timings(statsd, name, result, response)
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
