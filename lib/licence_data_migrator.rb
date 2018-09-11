require 'csv'

class LicenceDataMigrator
  MAPPING_FILENAME = 'correlation_id_to_gds_id_mappings.csv'.freeze

  attr_accessor :licence_mappings

  def self.migrate
    new(load_mappings).run
  end

  def initialize(mappings, output_stream = $stdout)
    @licence_mappings = mappings
    @output_stream = output_stream
  end

  def self.data_file_path(filename)
    Rails.root.join('data', filename)
  end

  def self.load_mappings
    licence_mappings = {}
    CSV.read(data_file_path(MAPPING_FILENAME), headers: true).each do |row|
      licence_mappings[row['correlation_id']] = row['gds_id']
    end
    licence_mappings
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

      counter += 1

      done(counter, "\r")
    end

    done(counter, "\n")
  end

  # https://docs.google.com/a/digital.cabinet-office.gov.uk/spreadsheet/ccc?key=0AiNczyuLA7LTdGwtVXItMnBPcXVIcV9RR19NbkZDWXc#gid=1
  def country_code licence
    return 7 if licence.da_northern_ireland && licence.da_england # All UK
    return 6 if licence.da_wales && licence.da_scotland # England Scotland and Wales
    return 5 if licence.da_wales && licence.da_england # England and Wales
    return 4 if licence.da_northern_ireland
    return 3 if licence.da_scotland
    return 2 if licence.da_wales
    return 1 if licence.da_england
  end

  def done(counter, newline)
    @output_stream.print "Migrated #{counter} Licences.#{newline}"
  end
end
