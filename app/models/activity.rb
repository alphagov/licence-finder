class Activity
  include Mongoid::Document
  field :public_id, :type => Integer
  index :public_id, :unique => true
  field :name, :type => String
  has_and_belongs_to_many :sectors

  validates :name, :presence => true

  def self.find_by_public_id(public_id)
    where(public_id: public_id).first
  end

  def self.find_by_public_ids(public_ids)
    self.any_in public_id: public_ids
  end

  def self.find_by_sectors(sectors)
    activity_ids = sectors.map(&:activity_ids).flatten
    self.any_in _id: activity_ids
  end

  def to_s
    self.name
  end
end
