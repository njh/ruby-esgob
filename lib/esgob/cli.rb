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
      client.domains_list.map {|h| [h[:domain], h[:type]]}
    )
  end

  desc "slaves", "List slave domains"
  def slaves
    print_table(
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
    result = yield
    unless result[:action].nil?
      say set_color("=> #{result[:action]}", :green, :bold)
    end
  end

end
