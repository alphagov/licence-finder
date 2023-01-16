class DataExporter
  def self.call
    new.call
  end

  def call
    licences = Licence.all
    licences.map do |licence|
      {
        licence_identifier: licence.gds_id,
        locations: locations(licence),
      }
    end
  end

private

  def locations(licence)
    locations = []
    locations << "england" if licence.da_england
    locations << "wales" if licence.da_wales
    locations << "scotland" if licence.da_scotland
    locations << "northern-ireland" if licence.da_northern_ireland

    locations
  end
end
