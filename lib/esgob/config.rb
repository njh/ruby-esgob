module Esgob::Config

  # Get an ordered list of paths to possible Esgob configuration files
  def self.file_paths
    [
      File.join(ENV['HOME'], '.esgob'),
      '/etc/esgob',
      '/usr/local/etc/esgob'
    ]
  end
end
