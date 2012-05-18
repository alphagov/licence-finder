class Licence
  include Mongoid::Document
  field :public_id, :type => Integer
  index :public_id, :unique => true
  field :correlation_id, :type => Integer
  index :correlation_id, :unique => true
  field :name, :type => String
  field :regulation_area, :type => String
  field :da_england, :type => Boolean
  field :da_scotland, :type => Boolean
  field :da_wales, :type => Boolean
  field :da_northern_ireland, :type => Boolean

  validates :name, :presence => true
  validates :regulation_area, :presence => true

  before_save :set_public_id

  def self.find_by_public_id(public_id)
    where(public_id: public_id).first
  end

  def self.find_by_correlation_id(correlation_id)
    where(correlation_id: correlation_id).first
  end

  def self.find_by_sectors_activities_and_location(sectors, activities, location)
    # consider moving location into licence_link to avoid two queries
    licence_links = LicenceLink.find_by_sectors_and_activities(sectors, activities)
    where(:_id.in => licence_links.map(&:licence_id), "da_#{location}".to_sym => true)
  end

  def set_public_id
    # TODO: factor out
    if self.public_id.nil?
      counter = Mongoid.database["counters"].find_and_modify(
          :query  => {:_id  => "licence"},
          :update => {:$inc => {:count => 1}},
          :new    => true,
          :upsert => true
      )["count"]
      self.public_id = counter
    end
  end
end
