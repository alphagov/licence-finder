class DataExporter
  def self.export_for(klass)
    records = []
    klass.all.each do |record|
      records << record
    end
    save_to_file(records.to_json, klass.to_s.downcase)
  end

  def self.save_to_file(data, filename)
    File.open("data/json/#{filename}.json", 'w') do |file|
      file.write(data)
    end
  end
end
