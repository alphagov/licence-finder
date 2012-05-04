class DataImporter::Activities < DataImporter
  FILENAME = 'activities.csv'

  def self.open_data_file
    File.open(data_file_path(FILENAME))
  end

  private

  def process_row(row)
    unless sector = Sector.find_by_public_id(row['SECTOR_OID'].to_i)
      Rails.logger.info "Can't find Sector #{row['SECTOR_OID']} (#{row['SECTOR']})"
      return
    end
    unless activity = Activity.find_by_public_id(row['BUSINSS_ACT_ID'].to_i)
      activity = Activity.new
      activity.public_id = row['BUSINSS_ACT_ID'].to_i
      activity.name = row['ACTIVITY_TITLE']
      Rails.logger.debug "Creating BusinessActivity #{activity.id}(#{activity.name})"
      activity.safely.save!
    end
    if sector.activities.nil?
      sector.activities = Array.new
    end
    if ! sector.activities.include? activity.id
      sector.activities << activity.id
      sector.safely.save!
    end
  end
end
