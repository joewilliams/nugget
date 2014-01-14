module Nugget
  class Web

    def self.run()
      app = Rack::URLMap.new('/'  => Nugget::Web.new)
      Thin::Server.start(Nugget::Config.ip, Nugget::Config.port, app)
    end

    def call(env)
      body = [File.read(Nugget::Config.resultsfile)]
      [200, { 'Content-Type' => 'text/plain' }, body]
    end

  end
end