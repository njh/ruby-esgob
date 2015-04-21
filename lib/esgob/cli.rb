require "thor"

class Esgob::CLI < Thor
  class_option :account,
               :type =>   :string,
               :aliases => '-a',
               :banner =>  'Account Name'

  class_option :key,
               :type =>   :string,
               :aliases => '-k',
               :banner =>  'API Key'

  class_option :verbose,
               :type =>  :boolean,
               :default => false,
               :aliases => '-v'


  desc "account", "Display account info"
  def account
    client.accounts_get.each_pair do |k,v|
      say sprintf("%8s: %s\n", k, v)
    end
  end

  desc "domains", "List all domains"
  def domains
    print_table(
      [['Domain', 'Type']] +
      [['------', '----']] +
      client.domains_list.map {|h| [h[:domain], h[:type]]}
    )
  end

  desc "slaves", "List slave domains"
  def slaves
    print_table(
      [['Domain', 'Master IP']] +
      [['------', '---------']] +
      client.domains_slaves_list.to_a
    )
  end

  desc "slaves-add DOMAIN MASTERIP", "Add new slave domain"
  def slaves_add(domain, masterip)
    check_action do
      client.domains_slaves_add(domain, masterip)
    end
  end

  desc "slaves-delete DOMAIN", "Delete a slave domain"
  def slaves_delete(domain)
    check_action do
      client.domains_slaves_delete(domain)
    end
  end

  desc "slaves-transfer DOMAIN",
       "Force transfer from master of a slave domain"
  def slaves_transfer(domain)
    check_action do
      client.domains_slaves_forcetransfer(domain)
    end
  end

  desc "slaves-update DOMAIN MASTERIP",
       "Updates the master IP of a slave domain"
  def slaves_update(domain, masterip)
    check_action do
      client.domains_slaves_updatemasterip(domain, masterip)
    end
  end

  desc "slaves-sync FILE MASTERIP",
       "Synronises list of slave domains in a file"
  def slaves_sync(filename, masterip)
    domains = []
    File.foreach(filename) do |line|
      domains << line.strip.split(/\s+/).first
    end

    check_action do
      client.domains_slaves_sync(domains, masterip)
    end
  end

  desc "soacheck DOMAIN",
       "Fetch domain SOA serial number for all nodes"
  def soacheck(domain)
    response = client.domains_tools_soacheck(domain)
    print_table(
      [['Identifier', 'Type', 'Country', 'SOA', 'Response']] +
      [['----------', '----', '-------', '---', '--------']] +
      response[:responses][:masters].map do |node|
        [node[:ip], "master", '', node[:soa], node[:response]]
      end + 
      response[:responses][:anycastnodes].map do |node|
        [node[:ref], 'anycast', node[:country], node[:soa], node[:response]]
      end
    )
  end

  desc "version", "Show Esgob Ruby Client version"
  def version
    say "Esgob Ruby Client version #{Esgob::VERSION}"
  end
  map "--version" => "version"


private ######################################################################

  def client
    @client ||= Esgob::Client.new(options[:account], options[:key])
  end
  
  def check_action
    begin
      results = yield
      results = [results] unless results.is_a?(Array)
      results.each do |result|
    unless result[:action].nil?
        say "#{result[:domain]} " + set_color("=> #{result[:action]}", :green, :bold)
      end
    end
    rescue Esgob::ServerError => err
      $stderr.puts set_color("=> Error: #{err.message} [#{err.code}]", :red, :bold)
    end
  end

end
