module Nugget
  class Service

    def self.run_daemon()
      Nugget::Log.info("Starting up Nugget in daemon mode ...")

      loop do
        run()

        # chill
        sleep(Nugget::Config.interval)
      end
    end

    def self.run_once()
      Nugget::Log.info("Starting up Nugget in run-once mode ...")
      run()
    end

    def self.run()
      config_file = File.new(Nugget::Config.config, 'r')
      parser = Yajl::Parser.new(:symbolize_keys => true)
      config = parser.parse(config_file)

      results = Hash.new

      config.each do |test, definition|
        result = nil
        response = nil

        begin
          request_definition = config_converter(definition)
          response_definition = definition[:response]

          response = Turd.run(request_definition, response_definition)
          result = "PASS"
        rescue Exception => e
          Nugget::Log.error("#{definition[:type]} test #{test} failed!")
          Nugget::Log.error(e)

          result = "FAIL"
          response = e.response
        end

        Nugget::Log.info("Test #{test} complete with status #{result}")

        results.store(test, {:config => definition, :result => result, :response => response})

        if Nugget::Config.backstop_url
          Nugget::Backstop.send_metrics(test, result, response)
        end
      end

      if Nugget::Config.daemon
        Nugget::Service.write_results(results)
      end
    end

    def self.config_converter(definition)
      options = definition[:request]

      if options[:method]
        sym_method = options[:method].to_sym
        options.store(:method, sym_method)
      end

      {
        :url => definition[:url],
        :type => definition[:type],
        :options => options
      }
    end

    def self.write_results(results)
      begin
        file = File.open(Nugget::Config.resultsfile, "w")
        file.puts(results.to_json)
        file.close
      rescue Exception => e
        Nugget::Log.error("Something went wrong with writing out the results file!")
        Nugget::Log.error(e)
      end
    end

  end
end