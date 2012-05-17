class Search
  def initialize(client)
    @client = client
  end

  def index_all
    @client.pre_index
    @client.index(Sector.all)
    @client.post_index
  end
end