require 'cgi'

class DataImporter::Licences < DataImporter
  FILENAME = 'licences.csv'

  def self.open_data_file
    File.open(data_file_path(FILENAME))
  end

  private

  def process_row(row)
    counter = 0
    sectors = find_sectors(row['SECTOR_OID'].to_i)
    if sectors.length == 0
      raise "Could not find sector #{row['SECTOR_OID']}, failing."
    end
    unless activity = Activity.find_by_correlation_id(row['BUSINESSACT_ID'].to_i)
      raise "Could not find activity #{row['BUSINESSACT_ID']}, failing."
    end
    unless licence = Licence.find_by_correlation_id(row['LICENCE_OID'].to_i)
      licence = Licence.new
      licence.correlation_id = row['LICENCE_OID'].to_i
      Rails.logger.debug "Creating licence #{licence.id}(#{licence.name})"
      counter += 1
    end
    licence.name = CGI.unescape_html( row['LICENCE'] )
    licence.regulation_area = row['REGULATION_AREA']
    licence.da_england = is_applicable_in(row, 'DA_ENGLAND')
    licence.da_scotland = is_applicable_in(row, 'DA_SCOTLAND')
    licence.da_wales = is_applicable_in(row, 'DA_WALES')
    licence.da_northern_ireland = is_applicable_in(row, 'DA_NIRELAND')
    licence.save!

    sectors.each do |sector|
      unless find_licence_link(sector, activity, licence).length > 0
        licence_join = LicenceLink.new
        licence_join.sector = sector
        licence_join.activity = activity
        licence_join.licence = licence
        licence_join.safely.save!
      end
    end
    counter
  end

  def find_licence_link(sector, activity, licence)
    LicenceLink.where(sector_id: sector.id, activity_id: activity.id, licence_id: licence.id)
  end

  def find_sectors(sector_id)
    sector = Sector.find_by_correlation_id(sector_id)
    if sector.layer < 3
      sector.children.map {|child| find_sectors(child.correlation_id)}.reduce {|a, b| a+b}
    else
      [sector]
    end
  end

  def is_applicable_in(row, devolved_authority)
    row[devolved_authority].to_i > 0 || row['ALL_OF_UK'].to_i > 0
  end
end
