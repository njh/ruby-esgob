class Esgob::Config
  # Path to the configuration file
  # @return [String]
  attr_accessor :filepath
  # @return [String]
  attr_accessor :endpoint
  # @return [String]
  attr_accessor :account
  # @return [String]
  attr_accessor :key

  DEFAULT_API_ENDPOINT = "https://api.esgob.com/1.0/".freeze

  # @param [Hash] args
  # @option args [String] :account The account name
  # @option args [String] :key The API key
  def initialize(args={})
    args.each_pair { |k, v| send("#{k}=", v) }
  end

  def endpoint
    # Use default endpoint if none configured
    @endpoint || DEFAULT_API_ENDPOINT
  end

  # Get an ordered list of paths to possible Esgob configuration files
  # @return [Array<String>] Array of file paths
  def self.default_filepaths
    [
      File.join(ENV['HOME'], '.esgob'),
      '/etc/esgob',
      '/usr/local/etc/esgob'
    ]
  end

  # Try and read Esgob configuration either from
  # Environment variables or one of the config files
  # @param [String] path Optional path to a configuration file
  # @return Esgob::Config
  def self.load(path=nil)
    if !path.nil?
      load_file(path)
    elsif ENV['ESGOB_ACCOUNT'] and ENV['ESGOB_KEY']
      self.new(
        :account => ENV['ESGOB_ACCOUNT'],
        :key => ENV['ESGOB_KEY']
      )
    else
      default_filepaths.each do |path|
        if File.exist?(path)
          return load_file(path)
        end
      end

      # No config file found, return nil
      nil
    end
  end

  # Save Esgob configuration to file
  # If no filepath is given, save to the default filepath
  # @param [String] path Optional path to a configuration file
  def save(path=nil)
    if !path.nil?
      self.filepath = path
    elsif filepath.nil?
      self.filepath = self.class.default_filepaths.first
    end

    File.open(filepath, 'wb') do |file|
      each_pair do |key,value|
        file.puts "#{key} #{value}"
      end
    end
  end

  # Calls block once for each configuration key value pair,
  # passing the key and value as parameters.
  def each_pair
    instance_variables.sort.each do |var|
      next if var.to_s == '@filepath'
      yield(var.to_s.sub(/^@/,''), instance_variable_get(var))
    end
  end


  protected

  def self.load_file(path)
    config = self.new(:filepath => path)

    File.foreach(path) do |line|
      if line =~ /^(\w+)\s+(.+)$/
        method, value = ["#{$1}=", $2]
        if config.respond_to?(method)
          config.send(method, value)
        end
      end
    end

    config
  end

end
