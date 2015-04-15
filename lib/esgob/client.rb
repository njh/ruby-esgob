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

    self.account  ||= ENV['ESGOB_ACCOUNT']
    self.api_key  ||= ENV['ESGOB_API_KEY']
    self.endpoint ||= DEFAULT_API_ENDPOINT

    if account.nil? or account.empty?
      raise(ArgumentError, "No account name configured for Esgob")
    end

    if api_key.nil? or api_key.empty?
      raise(ArgumentError, "No API key configured for Esgob")
    end
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

  # Returns all hosted slave domains as a hash
  #
  def domains_slaves_list
    Hash[
      call('domains.slaves.list')[:domains].map do |item|
        [item[:domain], item[:masterip]]
      end
    ]
  end

  # Adds a new slave domain
  def domains_slaves_add(domain, masterip)
    call('domains.slaves.add', :domain => domain, :masterip => masterip)
  end

  # Deletes a slave domain
  def domains_slaves_delete(domain)
    call('domains.slaves.delete', :domain => domain)
  end

  # Force AXFR / transfer from master of a slave domain
  def domains_slaves_forcetransfer(domain)
    call('domains.slaves.forcetransfer', :domain => domain)
  end

  # Updates the master IP of a slave domain
  def domains_slaves_updatemasterip(domain, masterip)
    call('domains.slaves.updatemasterip', :domain => domain, :masterip => masterip)
  end

  # Add a host allowed to AXFR out
  def domains_slaves_axfrout_add(domain, axfrip)
    call('domains.slaves.axfrout.add', :domain => domain, :axfrip => axfrip)
  end

  # Account	Delete a host allowed to AXFR out
  def domains_slaves_axfrout_delete(domain, axfrip)
    call('domains.slaves.axfrout.delete', :domain => domain, :axfrip => axfrip)
  end

  # Retrieve the domain SOA serial number from the master and each anycast node
  def domains_tools_soacheck(domain)
    call('domains.tools.soacheck', :domain => domain)
  end

  # Given a list of domains and a master IP, add and delete domains
  # so that the Esgob account matches the local list
  def domains_slaves_sync(domains, masterip)
    existing_domains = domains_slaves_list

    # Add any missing domains
    domains.each do |domain|
      unless existing_domains.include?(domain)
        domains_slaves_add(domain, masterip)
      end
    end

    # Now check the existing domains
    existing_domains.keys.each do |domain|
      if domains.include?(domain)
        # Update the masterip if it isn't correct
        if existing_domains[domain] != masterip
          domains_slaves_updatemasterip(domain, masterip)
        end
      else
        # Delete domain; not on list
        domains_slaves_delete(domain)
      end
    end
  end

  def inspect
    "\#<#{self.class} account=#{@account}>"
  end

  protected

  def symbolize_keys!(hash)
    hash.keys.each do |key|
      ks = key.to_sym
      hash[ks] = hash.delete(key)
      case hash[ks]
        when Hash
          symbolize_keys!(hash[ks])
        when Array
          hash[ks].each {|item| symbolize_keys!(item) if item.kind_of?(Hash)}
      end
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
    hash.keys.sort{|a,b| a.to_s <=> b.to_s}.map { |key|
      URI::escape(key.to_s) + '=' + URI::escape(hash[key].to_s)
    }.join('&')
  end
end
