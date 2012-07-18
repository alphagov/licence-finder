require 'csv'

class LicencesDataMigrator
  
  MAPPING_FILENAME = 'correlation_id_to_legal_ref_id_mappings.csv'
  LICENCES_FILENAME = 'licences.csv'
  
  attr_accessor :licence_mappings

  def self.migrate
    mapping_fh = open_mapping_file
    licences_fh = open_licences_file
    begin
      new(mapping_fh, licences_fh).run
    ensure
      mapping_fh.close
      licences_fh.close
    end
  end

  def self.data_file_path(filename)
    Rails.root.join('data', filename)
  end

  def self.open_mapping_file
    File.open(data_file_path(MAPPING_FILENAME))
  end
  
  def self.open_licences_file
    File.open(data_file_path(LICENCES_FILENAME))
  end

  def initialize(mapping_fh, licences_fh)
    @mapping_filehandle = mapping_fh
    @licences_filehandle = licences_fh
  end
  
  def cache_mappings(mapping_filehandle)
    @licence_mappings = {}
    CSV.new(mapping_filehandle, headers: true).each do |row|
      @licence_mappings[row['GDS ID']] = row['Legal_Ref_No']  
    end
    @licence_mappings.size
  end

  def run
    counter = 0
    
    cache_mappings(@mapping_filehandle)
    
    CSV.new(@licences_filehandle, headers: true).each do |row|
      counter += process_row(row)
      done(counter, "\r")
    end
    done(counter, "\n")
  end

  private

  def process_row(row)
    counter = 0
    
    row['LICENCE_OID'] = @licence_mappings[row['LICENCE_OID']]
    # TODO
    # Look up existing Licence
    # licence = Licence.find_by_legal_ref_id(row['LICENCE_OID'].to_i)
    # Update legal_ref_id
    # licence.legal_ref_id = @licence_mappings[row['LICENCE_OID']].to_i
    
    
    counter
  end

  def done(counter, nl)
    print "Imported #{counter} #{self.class.name.split('::').last}.#{nl}"
  end
  
end
