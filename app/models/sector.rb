require "public_id"

class Sector
  include Mongoid::Document
  include PublicId
  field :correlation_id, :type => Integer
  index :correlation_id, :unique => true
  field :name, :type => String
  field :layer, :type => Integer
  field :parent_ids, :type => Array
  index :parent_ids

  has_and_belongs_to_many :activities

  validates :name, :presence => true

  def self.find_by_public_id(public_id)
    self.find_by_public_ids([public_id]).first
  end

  def self.find_by_public_ids(public_ids)
    self.any_in public_id: public_ids
  end

  def self.find_by_correlation_id(correlation_id)
    where(correlation_id: correlation_id).first
  end

  def self.find_layer1_sectors()
    where(layer: 1)
  end

  def self.find_layer3_sectors()
    where(layer: 3)
  end

  def parents=(sectors)
    self.parent_ids = sectors.map(&:id)
  end

  def children
    Sector.where(parent_ids: self.id)
  end

  def parents
    Sector.where(_id: {"$in" => self.parent_ids || []})
  end

  def to_s
    self.name
  end
end
