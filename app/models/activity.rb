class Activity
  include Mongoid::Document
  field :public_id, :type => Integer
  index :public_id, :unique => true
  field :name, :type => String

  validates :name, :presence => true
end
