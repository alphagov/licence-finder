require 'search'
require 'search/client/elasticsearch'
def load_config(name)
  HashWithIndifferentAccess.new(YAML.load(File.read(Rails.root + 'config' + 'search' + name)))
end
$search = lambda {
  search_config = load_config('search.yml')
  client_name   = search_config[Rails.env][:client]
  client_config = load_config("#{client_name}.yml")
  client_config = client_config[Rails.env].merge(client_config[:all_envs] || {})
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
  $search = Search.new(client)
}.call