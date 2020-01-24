# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname
require "json"
require "date"

# Fetch HoneyDB data.
#
class LogStash::Inputs::Honeydb < LogStash::Inputs::Base
  config_name "honeydb"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "json"

  # Configurable variables
  # HoneyDB API ID.
  config :api_id, :validate => :string, :default => "invalid"
  # HoneyDB Threat Information API Secret Key.
  config :secret_key, :validate => :string, :default => "invalid" 
  # The default, `300`, means fetch data every 5 minutes.
  config :interval, :validate => :number, :default => 300
  # Debug for plugin development.
  config :debug, :validate => :boolean, :default => false

  public
  def register
    @host = Socket.gethostname
    @http = Net::HTTP.new('honeydb.io', 443)
    @http.set_debug_output($stdout) if @debug
    @get = Net::HTTP::Get.new("/api/sensor-data")
    @http.use_ssl = true

    # check if interval value is less than 5 minutes
    if @interval < 300
      @logger.warn("interval value is less than 5 minutes, setting interval to 5 minutes.")
      @interval = 300
    end

    @logger.info("Fetching HoneyDB data every #{interval / 60} minutes.")
  end # def register

  def run(queue)
    # we can abort the loop if stop? becomes true
    while !stop?
      if fetch(queue)
        @logger.info("Data retreived successfully.")
      end

      # because the sleep interval can be big, when shutdown happens
      # we want to be able to abort the sleep
      # Stud.stoppable_sleep will frequently evaluate the given block
      # and abort the sleep(@interval) if the return value is true
      #Stud.stoppable_sleep(@interval) { stop? }
      Stud.stoppable_sleep(@interval) { stop? }
    end # loop
  end # def run

  def fetch(queue)
    # get today's date for sensor-data-date parameter
    today = Time.utc.now.strftime("%Y-%m-%d")

    # Set up iniital get request and initial next_uri
    get = Net::HTTP::Get.new("/api/sensor-data?sensor-data-date=#{today}")
    from_id = "not zero"

    # Loop through results until next_uri is empty.
    while !from_id? "0"
      get["X-HoneyDb-ApiId"] = "#{@api_id}"
      get["X-HoneyDb-ApiKey"] = "#{@secret_key}"

      begin
        response = @http.request(get)
      rescue
        @logger.warn("Could not reach API endpoint to retreive data!")
        return false
      end

      if response.code? "524"
        @logger.warn("524 - Origin Timeout!")
        return false
      end

      if response.code? "401"
        @logger.warn("401 - Unauthorized!")
        return false
      end

      json = JSON.parse(response.body)

      # loop through json payloads
      json[0]['data'].each do |payload|
        # add the event
        event = LogStash::Event.new("message" => payload, "host" => @host)
        decorate(event)
        queue << event
      end

      # get the next uri value
      from_id = json[1]['from_id']

      # continue retreiving next_uri if it exists
      if !from_id? "0"
        get = Net::HTTP::Get.new("/api/sensor-data?sensor-data-date=#{today}&from_id#{from_id}")
      end
    end

    return true
  end

  def stop
    # nothing to do in this case so it is not necessary to define stop
    # examples of common "stop" tasks:
    #  * close sockets (unblocking blocking reads/accepts)
    #  * cleanup temporary files
    #  * terminate spawned threads
  end
end # class LogStash::Inputs::Honeydb
