class Licence
  include Mongoid::Document
  field :public_id, :type => Integer
  index :public_id, :unique => true
  field :name, :type => String
  field :regulation_area, :type => String
  field :da_england, :type => Boolean
  field :da_scotland, :type => Boolean
  field :da_wales, :type => Boolean
  field :da_northern_ireland, :type => Boolean

  validates :name, :presence => true
  validates :regulation_area, :presence => true
end
