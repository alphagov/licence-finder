class DataImporter::Activities < DataImporter
  FILENAME = "activities.csv".freeze

  def self.open_data_file
    File.open(data_file_path(FILENAME))
  end

private

  def process_row(row)
    counter = 0
    sector = Sector.find_by_correlation_id(row["SECTOR_OID"].to_i)
    if sector.nil?
      Rails.logger.info "Can't find Sector #{row['SECTOR_OID']} (#{row['SECTOR']})"
      return 0
    end
    activity = Activity.find_by_correlation_id(row["BUSINSS_ACT_ID"].to_i)
    if activity.nil?
      activity = Activity.new
      activity.correlation_id = row["BUSINSS_ACT_ID"].to_i
      activity.name = row["ACTIVITY_TITLE"]
      Rails.logger.debug "Creating BusinessActivity #{activity.id}(#{activity.name})"
      activity.save!
      counter += 1
    end
    if sector.activities.nil?
      sector.activities = []
    end
    unless sector.activities.include? activity
      sector.activities << activity
      sector.save!
    end
    counter
  end
end
