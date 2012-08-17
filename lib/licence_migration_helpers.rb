module LicenceMigrationHelpers
  
  MAPPING_FILENAME = 'correlation_id_to_gds_id_mappings.csv' unless defined? MAPPING_FILENAME
  
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  module ClassMethods
    
    def data_file_path(filename)
      Rails.root.join('data', filename)
    end
  
    def load_mappings
      licence_mappings = {}
      CSV.read(data_file_path(MAPPING_FILENAME), headers: true).each do |row|
        licence_mappings[row['correlation_id']] = row['gds_id']  
      end
      licence_mappings
    end
    
  end
  
  # https://docs.google.com/a/digital.cabinet-office.gov.uk/spreadsheet/ccc?key=0AiNczyuLA7LTdGwtVXItMnBPcXVIcV9RR19NbkZDWXc#gid=1
  def country_code licence
    return 7 if licence.da_northern_ireland and licence.da_england # All UK
    return 6 if licence.da_wales and licence.da_scotland # England Scotland and Wales
    return 5 if licence.da_wales and licence.da_england # England and Wales
    return 4 if licence.da_northern_ireland
    return 3 if licence.da_scotland
    return 2 if licence.da_wales
    return 1 if licence.da_england
  end  
  
end
