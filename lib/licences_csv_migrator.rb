require 'csv'

class LicencesCsvMigrator
  
  MAPPING_FILENAME = 'licence_mappings.csv'
  LICENCES_FILENAME = 'licences.csv'
  MIGRATED_FILENAME = 'migrated_licences.csv'
  UNMIGRATED_FILENAME = 'unmigrated_licences.csv'
  
  attr_accessor :licence_mappings

  def self.migrate
    begin
      migrated_csv = open_migrated_file
      unmigrated_csv = open_unmigrated_file
      
      new(migrated_csv, unmigrated_csv).run
      
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
    
  def self.data_file_path(filename)
    Rails.root.join('data', filename)
  end

  def initialize(migrated_csv, unmigrated_csv)
    @migrated_csv = migrated_csv
    @unmigrated_csv = unmigrated_csv
    @licence_mappings = load_mappings
    @licence_data = CSV.read(self.class.data_file_path(LICENCES_FILENAME), headers: true)
  end
  
  def load_mappings
    licence_mappings = {}
    data = CSV.read(self.class.data_file_path(MAPPING_FILENAME), headers: true)
    data.each do |row|
      licence_mappings[row['GDS ID']] = row['Legal_Ref_No']  
    end
    licence_mappings
  end

  def run
      
    counter = 0
    
    @licence_data.each do |row|
      
      counter += process_row(row)
      
      done(counter, "\r")
      
    end
    
    done(counter, "\n")
  end

  private

  def process_row(row)
    counter = 0
    legal_ref_id = @licence_mappings[row['LICENCE_OID']]
    if legal_ref_id
      
      row['LICENCE_OID'] = legal_ref_id
      @migrated_csv << row
      counter += 1
    else
      @unmigrated_csv << row
    end
    counter
  end

  def done(counter, nl)
    print "Migrated #{counter} Licences.#{nl}"
  end
  
end
