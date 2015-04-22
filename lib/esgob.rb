module Esgob
  autoload :Client,   'esgob/client'
  autoload :CLI,      'esgob/cli'
  autoload :VERSION,  'esgob/version'

  class ServerError < StandardError
    attr_reader :code

    def initialize(message, code = nil)
      super message
      @code = code
    end
  end
end
