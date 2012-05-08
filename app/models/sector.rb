class Sector
  include Mongoid::Document
  field :public_id, :type => Integer
  index :public_id, :unique => true
  field :name, :type => String
  field :activities, :type => Array
  field :layer1_id, :type => Integer # Only for the purpose of importing
  field :layer2_id, :type => Integer # Only for the purpose of importing

  validates :name, :presence => true

  def self.find_by_public_id(public_id)
    where(public_id: public_id).first
  end
end
