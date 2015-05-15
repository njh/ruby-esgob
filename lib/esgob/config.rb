class Esgob::Config
  # @return [String]
  attr_accessor :account
  # @return [String]
  attr_accessor :key

  # Get an ordered list of paths to possible Esgob configuration files
  def self.file_paths
    [
      File.join(ENV['HOME'], '.esgob'),
      '/etc/esgob',
      '/usr/local/etc/esgob'
    ]
  end
  
  def file_paths
    self.class.file_paths
  end
  
  
  def save(filepath=nil)
    filepath = file_paths.first if filepath.nil?
  
    File.open(filepath, 'wb') do |file|
      instance_variables.sort.each do |var|
        file.puts "#{var.to_s.sub(/^@/,'')} #{instance_variable_get(var)}"
      end
    end
  end
end
