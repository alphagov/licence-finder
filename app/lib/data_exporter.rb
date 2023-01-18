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
        industry_sectors: level_two_sectors(licence),
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

  def level_two_sectors(licence)
    sectors = Sector.in(id: LicenceLink.where(licence_id: licence.id).pluck(:sector_id))
    sectors.filter_map do |sector|
      parent_sectors = sector.parents.to_a
      parent_sectors.first.name.parameterize if parent_sectors.first&.layer == 2
    end
  end
end
