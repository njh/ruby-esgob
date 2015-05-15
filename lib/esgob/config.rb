class Esgob::Config
  # @return [String]
  attr_accessor :account
  # @return [String]
  attr_accessor :key

  # @param [Hash] args 
  # @option args [String] :account The account name
  # @option args [String] :key The API key
  def initialize(args={})
    args.each_pair { |k, v| send("#{k}=", v) }
  end

  # Get an ordered list of paths to possible Esgob configuration files
  # @return [Array<String>] Array of file paths
  def self.file_paths
    [
      File.join(ENV['HOME'], '.esgob'),
      '/etc/esgob',
      '/usr/local/etc/esgob'
    ]
  end
  
  # Get an ordered list of paths to possible Esgob configuration files
  # @return [Array<String>] Array of file paths
  def file_paths
    self.class.file_paths
  end
  
  # Try and read Esgob configuration either from 
  # Environment variables or one of the config files
  # @param [String] filepath Optional path to a configuration file
  # @return Esgob::Config
  def self.load(filepath=nil)
    if !filepath.nil?
      load_file(filepath)
    elsif ENV['ESGOB_ACCOUNT'] and ENV['ESGOB_KEY']
      self.new(
        :account => ENV['ESGOB_ACCOUNT'],
        :key => ENV['ESGOB_KEY']
      )
    else
      file_paths.each do |path|
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
  # @param [String] filepath Optional path to a configuration file
  def save(filepath=nil)
    filepath = file_paths.first if filepath.nil?
  
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
      yield(var.to_s.sub(/^@/,''), instance_variable_get(var))
    end
  end


  protected
  
  def self.load_file(filepath)
    config = self.new

    File.foreach(filepath) do |line|
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
