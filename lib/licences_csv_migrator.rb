require 'csv'
require 'licence_migration_helpers'

class LicencesCsvMigrator
  
  include LicenceMigrationHelpers
  
  LICENCES_FILENAME = 'licences.csv'
  MIGRATED_FILENAME = 'migrated_licences.csv'
  UNMIGRATED_FILENAME = 'unmigrated_licences.csv'
  
  attr_accessor :licence_mappings

  def self.migrate
    begin
      migrated_csv = open_migrated_file
      unmigrated_csv = open_unmigrated_file
      
      new(migrated_csv, unmigrated_csv, read_licence_data, load_mappings).run
      
    ensure
      migrated_csv.close
      unmigrated_csv.close
    end
  end
  
  def self.move_files
    FileUtils.mv(data_file_path(MIGRATED_FILENAME), data_file_path(LICENCES_FILENAME))
  end
  
  def self.open_migrated_file
    CSV.open(data_file_path(MIGRATED_FILENAME), "w", force_quotes: true)
  end
    
  def self.open_unmigrated_file
    CSV.open(data_file_path(UNMIGRATED_FILENAME), "w", force_quotes: true)
  end  
  
  def self.read_licence_data
    CSV.read(data_file_path(LICENCES_FILENAME), headers: true)
  end

  def initialize(migrated_csv, unmigrated_csv, licence_data, mappings)
    @migrated_csv = migrated_csv
    @unmigrated_csv = unmigrated_csv
    @licence_data = licence_data
    @licence_mappings = mappings
  end

  def run
      
    counter = 0
    @unmigrated_correlation_ids = []
    
    @migrated_csv << @licence_data.headers
    @unmigrated_csv << @licence_data.headers
    
    @licence_data.each do |row|
      counter += process_row(row)
      
      done(counter, "\r")
      
    end
    
    done(counter, "\n")
  end

  private

  def process_row(row)
    counter = 0
    gds_id = @licence_mappings[row['LICENCE_OID']]
    if gds_id
      
      row['LICENCE_OID'] = gds_id
      @migrated_csv << row
      counter += 1
    else
      unless @unmigrated_correlation_ids.include?(row['LICENCE_OID'])
        @unmigrated_correlation_ids << row['LICENCE_OID']
        @unmigrated_csv << row
      end
    end
    counter
  end

  def done(counter, nl)
    print "Replaced #{counter} LICENCE_OIDs.#{nl}"
  end
  
end
