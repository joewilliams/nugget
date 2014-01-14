module Nugget
  class Web

    def self.run()
      app = Rack::URLMap.new('/'  => Nugget::Web.new)
      Thin::Server.start(Nugget::Config.ip, Nugget::Config.port, app)
    end

    def call(env)
      time_diff = Time.now.to_i - File.mtime(Nugget::Config.resultsfile).to_i

      if time_diff < 3600
        body = [File.read(Nugget::Config.resultsfile)]
        [200, { 'Content-Type' => 'text/plain' }, body]
      else
        [500, { 'Content-Type' => 'text/plain' }, ["nugget results file over an hour old (#{time_diff} seconds)"]]
      end
    end

  end
end