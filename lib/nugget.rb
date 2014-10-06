require 'rubygems'

require 'bundler'
require 'bundler/setup'

require 'turd'
require 'mixlib/cli'
require 'mixlib/config'
require 'mixlib/log'
require 'yajl/json_gem'
require 'thin'
require 'statsd'
require 'open-uri'
require 'iconv' if RUBY_VERSION =~ /1.8/
require 'timeout'

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
require 'nugget/statsd'
require 'nugget/version'

TIMEOUT = 30

module  Nugget
  class << self

    def main
      cli = Nugget::CLI.new
      cli.parse_options
      Nugget::Config.merge!(cli.config)

      Nugget::Log.level(Nugget::Config.log_level)

      if Nugget::Config.web
        Nugget::Web.run()
      else
        if Nugget::Config.config
          if Nugget::Config.daemon
            Nugget::Service.run_daemon(Nugget::Config.test)
          else
            Nugget::Service.run_once(Nugget::Config.test)
          end
        else
          Nugget::Log.error("No config supplied! Use \"-c FILE\".")
        end
      end
    end

  end
end
