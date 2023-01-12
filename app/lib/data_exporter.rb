class DataExporter
  def self.call
    new.call
  end

  def call
    licences = Licence.all
    licences.map do |licence|
      {
        licence_identifier: licence.gds_id,
      }
    end
  end
end
