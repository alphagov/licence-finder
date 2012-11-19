require 'csv'
require 'json'

class DataImporter
  def self.import_for(klass)
    file = File.open("data/json/#{klass.to_s.downcase}.json", "rb")
    records = JSON.parse(file.read)
    file.close

    unless records.nil?
      records.each do |record|
        # symbolise keys.
        record.keys.each do |key|
          record[(key.to_sym rescue key) || key] = record.delete(key)
        end

        klass.create!(record)
      end
    end
  end
end
