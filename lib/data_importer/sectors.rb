class DataImporter::Sectors < DataImporter
  FILENAME = 'sectors.csv'

  def self.open_data_file
    File.open(data_file_path(FILENAME))
  end

  private

  def process_row(row)
    if Sector.find_by_public_id(row['LAYER3_OID'].to_i)
      Rails.logger.info "Skipping Layer3 sector #{row['LAYER3_OID']}(#{row['LAYER3']})"
    else
      layer3 = Sector.new
      layer3.public_id = row['LAYER3_OID'].to_i
      layer3.name = row['LAYER3']
      layer3.layer1_id = row['LAYER1_OID'].to_i
      layer3.layer2_id = row['LAYER2_OID'].to_i
      Rails.logger.debug "Creating Layer3 sector #{layer3.id}(#{layer3.name})"
      layer3.safely.save!
    end
  end
end
