class Search
  attr_accessor :client

  def self.create_for_config(client_name, environment)
    config_path = Rails.root + 'config' + 'search' + "#{client_name}.yml"
    client_config = HashWithIndifferentAccess.new(YAML.load(File.read(config_path)))
    client_config = client_config[environment].merge(client_config[:all_envs])
    if client_name.to_sym == :elasticsearch
      Rails.logger.instance_eval do
        alias :write :info
      end
      client = Search::Client::Elasticsearch.new(client_config.merge(logger: Rails.logger))
    elsif client_name.to_sym == :solr
      client = Search::Client::Solr.new(client_config)
    else
      raise "Invalid search client configured #{client_name}"
    end
    Search.new(client)
  end

  def initialize(client)
    @client = client
  end

  def index_all
    @client.pre_index
    @client.index(Sector.find_layer3_sectors)
    @client.post_index
  end

  def delete_index
    @client.delete_index
  end

  def search(query)
    public_ids = @client.search(query)

    Sector.find_by_public_ids(public_ids).to_a.sort do |a, b|
      public_ids.index(a.public_id) <=> public_ids.index(b.public_id)
    end
  end
end