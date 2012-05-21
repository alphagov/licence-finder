require "public_id"

class Sector
  include Mongoid::Document
  include PublicId
  field :correlation_id, :type => Integer
  index :correlation_id, :unique => true
  field :name, :type => String
  field :layer1_id, :type => Integer # Only for the purpose of importing
  field :layer2_id, :type => Integer # Only for the purpose of importing
  has_and_belongs_to_many :activities

  validates :name, :presence => true

  def self.find_by_public_ids(public_ids)
    self.any_in public_id: public_ids
  end

  def self.find_by_correlation_id(correlation_id)
    where(correlation_id: correlation_id).first
  end

  def to_s
    self.name
  end
end
