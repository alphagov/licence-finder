class LicenceLink
  include Mongoid::Document

  belongs_to :sector
  belongs_to :activity
  belongs_to :licence

  validates :sector_id, :presence => true
  validates :activity_id, :presence => true
  validates :licence_id, :presence => true
end
