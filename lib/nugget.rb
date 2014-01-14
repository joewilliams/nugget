require 'rubygems'

require '/Users/joe/src/turd/lib/turd'
require 'mixlib/cli'
require 'mixlib/config'
require 'mixlib/log'
require 'yajl/json_gem'
require 'thin'

__DIR__ = File.dirname(__FILE__)

$LOAD_PATH.unshift __DIR__ unless
  $LOAD_PATH.include?(__DIR__) ||
  $LOAD_PATH.include?(File.expand_path(__DIR__))

require 'nugget/config'
require 'nugget/log'
require 'nugget/cli'
require 'nugget/service'
require 'nugget/web'
require 'nugget/backstop'

module  Nugget
  class << self

    def main
      cli = Nugget::CLI.new
      cli.parse_options
      Nugget::Config.merge!(cli.config)

      Nugget::Log.level(Nugget::Config.log_level)

      if Nugget::Config.daemon
        Nugget::Service.run_daemon()
      elsif Nugget::Config.web
        Nugget::Web.run()
      else
        Nugget::Service.run_once()
      end
    end

  end
end