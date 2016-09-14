class Licence
  include Mongoid::Document
  # Deprecated attr left here for smoother migration.
  field :correlation_id, type: Integer
  index({ correlation_id: 1 }, unique: true)
  field :gds_id, type: String
  index({ gds_id: 1 }, unique: true)
  field :name, type: String
  field :regulation_area, type: String
  field :da_england, type: Boolean
  field :da_scotland, type: Boolean
  field :da_wales, type: Boolean
  field :da_northern_ireland, type: Boolean

  validates :name, presence: true
  validates :regulation_area, presence: true

  def self.find_by_correlation_id(correlation_id)
    where(correlation_id: correlation_id).first
  end

  def self.find_by_gds_id(gds_id)
    where(gds_id: gds_id).first
  end

  def self.find_by_sectors_activities_and_location(sectors, activities, location)
    # consider moving location into licence_link to avoid two queries
    licence_links = LicenceLink.find_by_sectors_and_activities(sectors, activities)
    where(:_id.in => licence_links.map(&:licence_id), "da_#{location}".to_sym => true)
  end
end
