
class Esgob::Client
  attr_accessor :endpoint
  attr_accessor :account
  attr_accessor :api_key
  
  DEFAULT_API_ENDPOINT = "https://api.esgob.com/1.0/".freeze

  def initialize(*args)
    if args.first.kind_of?(Hash)
      hash = args.first
      self.account = hash[:account]
      self.api_key = hash[:api_key]
    else
      self.account = args[0]
      self.api_key = args[1]
    end

    self.endpoint = DEFAULT_API_ENDPOINT
    self.account ||= ENV['ESGOB_ACCOUNT']
    self.api_key ||= ENV['ESGOB_API_KEY']
  end

end
