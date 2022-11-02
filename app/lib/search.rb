require "erb"

class Search
  include Singleton

  attr_accessor :client

  def initialize
    environment = Rails.env
    config_path = Rails.root.join("config/elasticsearch.yml")
    client_config = HashWithIndifferentAccess.new(YAML.safe_load(ERB.new(File.read(config_path)).result))
    client_config = client_config[environment].merge(client_config[:all_envs])
    index_name = client_config.delete(:index)
    settings = client_config.delete(:create)
    type = client_config.delete(:type)

    Rails.logger.instance_eval do
      alias :write :info
    end

    @client = Search::Client::Elasticsearch.new(
      index_name:,
      settings:,
      type:,
      config: client_config.merge(
        logger: Rails.logger,
        log: true,
      ),
    )
  end

  def index_all
    client.pre_index
    client.index(Sector.find_layer3_sectors)
    client.post_index
  end

  delegate :delete_index, to: :client

  def search(query)
    public_ids = client.search(query)

    Sector.find_by_public_ids(public_ids).to_a.sort do |a, b|
      public_ids.index(a.public_id) <=> public_ids.index(b.public_id)
    end
  end
end
