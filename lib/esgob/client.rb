require "net/https"
require "uri"
require "json"

class Esgob::Client
  attr_accessor :endpoint
  attr_accessor :account
  attr_accessor :api_key
  
  DEFAULT_API_ENDPOINT = "https://api.esgob.com/1.0/".freeze

  def initialize(*args)
    if args.first.kind_of?(Hash)
      args.first.each_pair { |k,v| send("#{k}=", v) }
    else
      self.account = args[0]
      self.api_key = args[1]
    end

    self.endpoint ||= DEFAULT_API_ENDPOINT
    self.account  ||= ENV['ESGOB_ACCOUNT']
    self.api_key  ||= ENV['ESGOB_API_KEY']
  end
  
  def call(function_name, arguments={})
    uri = URI(endpoint + function_name)
    uri.query = build_query(default_arguments.merge(arguments))

    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      req = Net::HTTP::Get.new(uri.request_uri)
      req['Accept'] = 'application/json'
      http.request(req)
    end      

    if res.code =~ /^2/
      if res.content_type == 'application/json'
        symbolize_keys! JSON.parse(res.body)
      else
       raise "HTTP response from ESGOB is not of type JSON"
     end
    else
      # The badly named method throws an Net::HTTP exception
      res.value
    end
  
  end
  
  # Return account status; credit balance, etc
  def accounts_get
    call('accounts.get')
  end
  
  # Returns all hosted domains
  def domains_list
    call('domains.list')[:domains]
  end
  
  # Returns all hosted slave domains
  def domains_slaves_list
    call('domains.slaves.list')[:domains]
  end
  
  # Adds a new slave domain
  def domains_slaves_add(domain, masterip)
    call('domains.slaves.add', :domain => domain, :masterip => masterip)
  end
  
  # Deletes a slave domain
  def domains_slaves_delete(domain)
    call('domains.slaves.delete', :domain => domain)
  end
  
  end
  
  
  protected

  def symbolize_keys!(hash)
    hash.keys.each do |key|
      ks = key.to_sym
      hash[ks] = hash.delete(key)
      symbolize_keys!(hash[ks]) if hash[ks].kind_of?(Hash)
    end
    return hash
  end

  def default_arguments
    {
      :account => account,
      :key => api_key,
      :f => 'json'
    }
  end

  def build_query(hash)
    hash.keys.sort.map { |key|
      URI::escape(key.to_s) + '=' + URI::escape(hash[key].to_s)
    }.join('&')
  end
end
