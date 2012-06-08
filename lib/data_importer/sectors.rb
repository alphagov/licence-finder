class DataImporter::Sectors < DataImporter
  FILENAME = 'sectors.csv'

  def self.open_data_file
    File.open(data_file_path(FILENAME))
  end

  private

  def process_row(row)
    counter = 0
    layer1 = Sector.find_by_correlation_id(row['LAYER1_OID'].to_i)
    unless layer1
      layer1 = Sector.new
      layer1.correlation_id = row['LAYER1_OID'].to_i
      layer1.name = row['LAYER1']
      layer1.layer = 1
      layer1.safely.save!
      counter += 1
    end

    layer2 = Sector.find_by_correlation_id(row['LAYER2_OID'].to_i)
    unless layer2
      layer2 = Sector.new
      layer2.correlation_id = row['LAYER2_OID'].to_i
      layer2.name = row['LAYER2']
      layer2.layer = 2
      layer2.safely.save!
      counter += 1
    end

    l2parents = layer2.parents.to_a
    unless l2parents.include?(layer1)
      layer2.parents = l2parents + [layer1]
      layer2.safely.save!
    end

    layer3 = Sector.find_by_correlation_id(row['LAYER3_OID'].to_i)
    unless layer3
      layer3 = Sector.new
      layer3.correlation_id = row['LAYER3_OID'].to_i
      layer3.name = row['LAYER3']
      layer3.layer = 3
      layer3.safely.save!
      counter += 1
    end

    l3parents = layer3.parents.to_a
    unless l3parents.include?(layer2)
      layer3.parents = l3parents + [layer2]
      layer3.safely.save!
      counter += 1
    end
    counter
  end
end
