require 'thor'

module MilkMaid
  class CLI < Thor
    desc 'monitor_batch', "Start Monitoring a batch"
    long_desc <<-DESC

    `monitor_batch BATCH_NAME` will create a batch called BATCH_NAME
    and begin monitoring it for 30 minutes

    DESC
    option :batch_name, :type => :string, :required => :true, :aliases => "-b"
    option :temperature, :type => :numeric, :required => :false, :default => 30, :aliases => '-t'
    option :duration, :type => :numeric, :required => false, :default => 30, :aliases => '-d'
    option :logger, :type => :string, :required => false, :default => 'Console', :aliases => '-l'
    option :sensor, :type => :boolean, :required => false, :default => true, :aliases => '-s'
    def monitor_batch
      batch_name = options[:batch_name]
      temperature = options[:temperature].to_i
      duration = options[:duration].to_i
      logger_type = options[:logger]
      sensor_type = options[:sensor]

      sensor = get_sensor(sensor_type)
      notifier = get_logger(logger_type)
      batch = ::MilkMaid::Batch.new(name: batch_name, temperature: temperature, duration: duration, notifier: notifier, sensor: sensor)

      batch.start
    rescue ::MilkMaid::SensorException => e
      puts e.message
    end

    no_commands do
      def get_sensor(sensor_type)
        sensor_type ? ::MilkMaid::TemperatureSensor.new : ::MilkMaid::MockTemperatureSensor.new(options[:temperature].to_i - 20, options[:temperature].to_i + 30)
      end

      def get_logger(logger_type)
        case logger_type.upcase
        when 'CONSOLE'
          ::MilkMaid::ConsoleNotifier.new
        when 'WEB'
          ::MilkMaid::ParseNotifier.new
        end
      end
    end
  end
end
