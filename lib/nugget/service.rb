module Nugget
  class Service

    def self.run_daemon(test_name = nil)
      Nugget::Log.info("Starting up Nugget in daemon mode ...")

      loop do
        Nugget::Log.debug("Running tests ...")
        run(test_name)

        # chill
        Nugget::Log.debug("Sleeping for #{Nugget::Config.interval.to_i} ...")
        sleep(Nugget::Config.interval.to_i)
      end
    end

    def self.run_once(test_name = nil)
      Nugget::Log.info("Starting up Nugget in run-once mode ...")
      run(test_name)
    end

    def self.run(test_name = nil)
      config_file = open(Nugget::Config.config)
      parser = Yajl::Parser.new(:symbolize_keys => true)
      config = parser.parse(config_file)

      results = Hash.new
      threadlist = Array.new

      if test_name
        if definition = config[test_name.to_s.to_sym]
          run_test(results, test_name, definition)
        else
          raise "No test name #{test_name.inspect} found."
        end
      else
        config.each do |test, definition|
          threadlist << Thread.new { run_test(results, test, definition) }
        end
      end

      threadlist.each { |x|
          x.join
      }

      Nugget::Service.write_results(results)
    end

    def self.run_test(results, test, definition)
      result = nil
      response = nil

      begin
        request_definition = config_converter(definition)
        response_definition = definition[:response]

        status = Timeout::timeout(TIMEOUT) {
          Nugget::Log.debug("Asserting turd definitions ...")
          response = Turd.run(request_definition, response_definition)
        }
        result = "PASS"
      rescue Timeout::Error => e
        Nugget::Log.error("#{definition[:type]} test #{test} took too long to run (#{TIMEOUT}s)!")
        Nugget::Log.error(e)

        result = "FAIL"
        response = "timeout"
      rescue Exception => e
        Nugget::Log.error("#{definition[:type]} test #{test} failed due to #{e.response[:failed]}!")
        Nugget::Log.error(e)

        result = "FAIL"
        response = e.response
      end

      Nugget::Log.info("Test #{test} complete with status #{result}")

      results.store(test, {
        :config => request_definition,
        :result => result,
        :response => response,
        :timestamp => Time.now.to_i
      })

      send_metrics(test, result, response)
    end

    def self.config_converter(definition)
      options = definition[:request]

      if options[:method]
        sym_method = options[:method].to_sym
        options.store(:method, sym_method)
      end

      if options[:url]
        url = options[:url]
        options.delete(:url)
      end

      {
        :url => url,
        :type => definition[:type],
        :options => options
      }
    end

    def self.write_results(results)
      begin
        if Nugget::Config.resultsfile
          Nugget::Log.debug("Writing results to #{Nugget::Config.resultsfile} ...")
          file = File.open(Nugget::Config.resultsfile, "w")
          file.puts(results.to_json)
          file.close
        end
      rescue Exception => e
        Nugget::Log.error("Something went wrong with writing out the results file!")
        Nugget::Log.error(e)
      end
    end

    def self.send_metrics(test, result, response)
      if Nugget::Config.backstop_url
        Nugget::Backstop.send_metrics(test, result, response)
      end

      if Nugget::Config.statsd_host
        Nugget::NStatsd.send_metrics(test, result, response)
      end
    end

  end
end
