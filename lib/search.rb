class Search
  attr_accessor :client

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