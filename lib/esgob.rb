module Esgob
  autoload :Client,   'esgob/client'
  autoload :Config,   'esgob/config'
  autoload :CLI,      'esgob/cli'
  autoload :VERSION,  'esgob/version'

  # Exception raised when the Esgob API returns an error
  class ServerError < StandardError
    # Get the error code number returned by Esgob
    attr_reader :code

    def initialize(message, code = nil)
      super message
      @code = code
    end
  end
  
  # Exception raised if client is configured
  class UnconfiguredError < StandardError; end
end
