require "net/https"
require "uri"
require "json"

class Esgob::Client
  # @return [String]
  attr_accessor :endpoint
  # @return [String]
  attr_accessor :account
  # @return [String]
  attr_accessor :api_key

  DEFAULT_API_ENDPOINT = "https://api.esgob.com/1.0/".freeze

  # Create a new Esgob Client instance.
  #
  # @overload initialize
  #   Create a new client, using the ESGOB_ACCOUNT and ESGOB_API_KEY environment variables.
  # @overload initialize(account, key)
  #   @param [String] account
  #   @param [String] key
  # @overload initialize(args)
  #   @param [Hash] options 
  #   @option options [String] :endpoint The URI of the API endpoint
  #   @option options [String] :account The account name
  #   @option options [String] :api_key The API key
  # @return [Esgob::Client] A new client instance.
  # @example
  #   client = Esgob::Client.new('account', 'key')
  def initialize(*args)
    if args.first.is_a?(Hash)
      args.first.each_pair { |k, v| send("#{k}=", v) }
    else
      self.account = args[0]
      self.api_key = args[1]
    end

    self.account ||= ENV['ESGOB_ACCOUNT']
    self.api_key ||= ENV['ESGOB_API_KEY']
    self.endpoint ||= DEFAULT_API_ENDPOINT

    if account.nil? or account.empty?
      raise(ArgumentError, "No account name configured for Esgob")
    end

    if api_key.nil? or api_key.empty?
      raise(ArgumentError, "No API key configured for Esgob")
    end
  end

  # Call a named Esgob API function.
  #
  # @param [String] function_name The name of API function.
  # @param [Hash] args Pairs of argument keys and values.
  # @return [Hash] The response from the Esgob service, with symbols as keys.
  # @example client.call('domains.slaves.add', :domain => 'example.com', :masterip => '192.168.0.1')
  def call(function_name, args = {})
    uri = URI(endpoint + function_name)
    uri.query = build_query(default_arguments.merge(args))

    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      req = Net::HTTP::Get.new(uri.request_uri)
      req['Accept'] = 'application/json'
      http.request(req)
    end

    if res.content_type == 'application/json'
      data = symbolize_keys! JSON.parse(res.body)
      if data.key?(:error)
        raise Esgob::ServerError.new(
          data[:error][:message],
          data[:error][:code].to_s
        )
      elsif res.code !~ /^2/
        raise Esgob::ServerError.new(res.message, res.code)
      else
        return data
      end
    else
      raise "HTTP response from ESGOB is not of type JSON"
    end
  end

  # Return account status; credit balance, etc.
  # @return [Hash] Key, value pairs, containing account information.
  def accounts_get
    account = call('accounts.get')
    account[:added] = Time.at(account[:added]) if account[:added].is_a?(Fixnum)
    account
  end

  # Returns all hosted domains
  # @return [Array<Hash>] Array of hashes, one per domain.
  def domains_list
    call('domains.list')[:domains]
  end

  # Returns all hosted slave domains as a hash
  # @return [Hash] Domain name as key, master ip as value
  def domains_slaves_list
    Hash[
      call('domains.slaves.list')[:domains].map do |item|
        [item[:domain], item[:masterip]]
      end
    ]
  end

  # Adds a new slave domain.
  # @param [String] domain The name of the domain to add
  # @param [String] masterip The IP of the master to transfer the zone from.
  # @return [Hash] The response from the Esgob service, with symbols as keys.
  def domains_slaves_add(domain, masterip)
    result = call('domains.slaves.add', :domain => domain, :masterip => masterip)
    result[:domain] ||= domain
    result
  end

  # Deletes a slave domain.
  # @param [String] domain The name of the domain to delete.
  # @return [Hash] The response from the Esgob service, with symbols as keys.
  def domains_slaves_delete(domain)
    result = call('domains.slaves.delete', :domain => domain)
    result[:domain] ||= domain
    result
  end

  # Force AXFR / transfer from master of a slave domain
  # @param [String] domain The name of the domain to transfer.
  # @return [Hash] The response from the Esgob service, with symbols as keys.
  def domains_slaves_forcetransfer(domain)
    result = call('domains.slaves.forcetransfer', :domain => domain)
    result[:domain] ||= domain
    result
  end

  # Updates the master IP of a slave domain
  # @param [String] domain The name of the domain to update
  # @param [String] masterip The new IP of the master to transfer the zone from.
  # @return [Hash] The response from the Esgob service, with symbols as keys.
  def domains_slaves_updatemasterip(domain, masterip)
    result = call('domains.slaves.updatemasterip', :domain => domain, :masterip => masterip)
    result[:domain] ||= domain
    result
  end

  # Add a host allowed to AXFR out
  # @param [String] domain The name of the domain to update
  # @param [String] axfrip The new IP of the host to allow transfers to.
  # @return [Hash] The response from the Esgob service, with symbols as keys.
  def domains_slaves_axfrout_add(domain, axfrip)
    result = call('domains.slaves.axfrout.add', :domain => domain, :axfrip => axfrip)
    result[:domain] ||= domain
    result
  end

  # Account	Delete a host allowed to AXFR out
  # @param [String] domain The name of the domain to update
  # @param [String] axfrip The IP of the host to stop allowing transfers to.
  # @return [Hash] The response from the Esgob service, with symbols as keys.
  def domains_slaves_axfrout_delete(domain, axfrip)
    result = call('domains.slaves.axfrout.delete', :domain => domain, :axfrip => axfrip)
    result[:domain] ||= domain
    result
  end

  # Retrieve the domain SOA serial number from the master and each anycast node
  # @param [String] domain The name of the domain to look up
  # @return [Hash] The response from the Esgob service, with symbols as keys.
  def domains_tools_soacheck(domain)
    call('domains.tools.soacheck', :domain => domain)
  end

  # Given a list of domains and a master IP, add and delete domains
  # so that the Esgob account matches the local list
  # @param [Array<String>] domains The an array of domains to add to Esgob
  # @param [String] masterip The master IP address to use for all the domains
  # @return [Array<Hash>] A list of responses from the Esgob service
  def domains_slaves_sync(domains, masterip)
    existing_domains = domains_slaves_list

    # Add any missing domains
    responses = []
    domains.each do |domain|
      unless existing_domains.include?(domain)
        response = domains_slaves_add(domain, masterip)
        response[:domain] ||= domain
        responses << response
      end
    end

    # Now check the existing domains
    existing_domains.keys.sort.each do |domain|
      if domains.include?(domain)
        # Update the masterip if it isn't correct
        if existing_domains[domain] != masterip
          response = domains_slaves_updatemasterip(domain, masterip)
          response[:domain] ||= domain
          responses << response
        end
      else
        # Delete domain; not on list
        response = domains_slaves_delete(domain)
        response[:domain] ||= domain
        responses << response
      end
    end

    responses
  end

  # @return [String]
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
          hash[ks].each { |item| symbolize_keys!(item) if item.is_a?(Hash) }
      end
    end
    hash
  end

  def default_arguments
    {
      :account => account,
      :key => api_key,
      :f => 'json'
    }
  end

  def build_query(hash)
    hash.keys.sort { |a, b| a.to_s <=> b.to_s }.map do |key|
      URI.escape(key.to_s) + '=' + URI.escape(hash[key].to_s)
    end.join('&')
  end
end
