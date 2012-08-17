require 'csv'
require 'licence_migration_helpers'

class LicenceDataMigrator

  include LicenceMigrationHelpers
    
  attr_accessor :licence_mappings

  def self.migrate    
    new(load_mappings).run
  end

  def initialize(mappings)
    @licence_mappings = mappings
  end
  


  def run
      
    counter = 0
    gds_sequence = 9000
    
    Licence.all.each do |licence|
      
      gds_id = @licence_mappings[licence.correlation_id.to_s]
      
      if gds_id.nil?
        gds_id = "#{gds_sequence}-#{country_code(licence)}-1"
        gds_sequence += 1
      end
      
      licence.gds_id = gds_id
      licence.save!
      
      counter += 1 if gds_id
      
      done(counter, "\r")
      
    end
    
    done(counter, "\n")
  end
  
  def done(counter, nl)
    print "Migrated #{counter} Licences.#{nl}"
  end
  
end
