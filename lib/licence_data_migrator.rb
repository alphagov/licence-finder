require 'csv'

class LicenceDataMigrator
  
  MAPPING_FILENAME = 'licence_mappings.csv'
  
  attr_accessor :licence_mappings

  def self.migrate
    new().run
  end
      
  def self.data_file_path(filename)
    Rails.root.join('data', filename)
  end

  def initialize
    @licence_mappings = load_mappings
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
    
    Licence.all.each do |licence|
      
      puts "\nLooking up #{licence.correlation_id}\n"
      
      legal_ref_id = @licence_mappings[licence.correlation_id.to_s]
      
      if legal_ref_id
      
        puts "\nFound #{legal_ref_id}\n"
        licence.update_attribute("legal_ref_id", legal_ref_id.to_i)
        counter += 1
      end
      
      done(counter, "\r")
      
    end
    
    done(counter, "\n")
  end

  def done(counter, nl)
    print "Migrated #{counter} Licences.#{nl}"
  end
  
end
