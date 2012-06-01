class DataImporter::Activities < DataImporter
  FILENAME = 'activities.csv'

  def self.open_data_file
    File.open(data_file_path(FILENAME))
  end

  private

  def process_row(row)
    counter = 0
    unless sector = Sector.find_by_correlation_id(row['SECTOR_OID'].to_i)
      Rails.logger.info "Can't find Sector #{row['SECTOR_OID']} (#{row['SECTOR']})"
      return 0
    end
    unless activity = Activity.find_by_correlation_id(row['BUSINSS_ACT_ID'].to_i)
      activity = Activity.new
      activity.correlation_id = row['BUSINSS_ACT_ID'].to_i
      activity.name = row['ACTIVITY_TITLE']
      Rails.logger.debug "Creating BusinessActivity #{activity.id}(#{activity.name})"
      activity.safely.save!
      counter += 1
    end
    if sector.activities.nil?
      sector.activities = Array.new
    end
    unless sector.activities.include? activity
      sector.activities << activity
      sector.safely.save!
    end
    counter
  end
end
