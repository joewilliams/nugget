module Nugget
  class CLI
    include Mixlib::CLI

    option :log_level,
      :short => "-l LEVEL",
      :long  => "--log_level LEVEL",
      :description => "Set the log level (debug, info, warn, error, fatal)",
      :default => :info,
      :proc => Proc.new { |l| l.to_sym }

    option :interval,
      :short => "-i SECONDS",
      :long => "--interval SECONDS",
      :default => 30,
      :description => "How long Nugget waits between testing runs when in daemon mode."

    option :config,
      :short => "-c PATH",
      :long => "--config PATH",
      :description => "Path of the json config."

    option :test,
      :short => "-t TEST_NAME",
      :long => "--test TEST_NAME",
      :description => "Individual test name to run."

    option :daemon,
      :short => "-d",
      :long => "--daemon",
      :boolean => true,
      :default => false,
      :description => "Run as a daemon. If not specified nugget just runs once."

    option :web,
      :short => "-w",
      :long => "--web",
      :boolean => true,
      :description => "Run the web service."

    option :ip,
      :short => "-z IP",
      :long => "--ip IP",
      :default => "0.0.0.0",
      :description => "IP for the web service."

    option :port,
      :short => "-p PORT",
      :long => "--port PORT",
      :default => 3000,
      :description => "Port for the web service."

    option :backstop_url,
      :short => "-b URL",
      :long => "--backstop URL",
      :description => "URL for backstop metrics thing."

    option :resultsfile,
      :short => "-r FILE",
      :long => "--results FILE",
      :default => "/tmp/nugget_results.json",
      :description => "Path to where results file is written/read."

    option :help,
      :short => "-h",
      :long => "--help",
      :description => "Show this message",
      :on => :tail,
      :boolean => true,
      :show_options => true,
      :exit => 0

  end
end
