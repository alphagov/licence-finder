desc "Import all data from the CSV files"
task data_import: ["data_import:sectors", "data_import:activities", "data_import:licences"]

namespace :data_import do
  desc "Import all data"
  task all: :environment do
    DataImporter::Sectors.call
    DataImporter::Activities.call
    DataImporter::Licences.call
  end

  desc "Import all sector data"
  task sectors: :environment do
    DataImporter::Sectors.call
  end

  desc "Import all activity data"
  task activities: :environment do
    DataImporter::Activities.call
  end

  desc "Import all licence data"
  task licences: :environment do
    DataImporter::Licences.call
    # Now migrate the imported licences to use the new gds_id
    LicenceDataMigrator.migrate
  end

  desc "Import costs lawyers practicising certificate"
  task costs_lawyers_practicsing_certificate: :environment do
    gds_id_prefix = 9266 # Should be one more than the max ID from the database - Licence.pluck(:gds_id).max

    # region_code:
    # 1 - England
    # 2 - Wales
    # 3 - Scotland
    # 4 - Northern Ireland
    # 5 - England & Wales
    # 6 - England & Wales & Scotland
    # 7 - England & Wales & Scotland & Northern Ireland
    region_code = 5

    unique_suffix = 1 # Can always be 1, since we're incrementing the prefix so they're always unique

    gds_id = "#{gds_id_prefix}-#{region_code}-#{unique_suffix}"

    if Licence.where(gds_id: gds_id).any?
      raise "There's already a licence for gds_id #{gds_id}"
    end

    licence = Licence.new

    licence.da_england = true
    licence.da_wales = true
    licence.da_scotland = false
    licence.da_northern_ireland = false

    licence.gds_id = gds_id

    max_correlation_id = Licence.pluck(:correlation_id).max.to_i
    licence.correlation_id = (max_correlation_id + 1).to_s

    licence.name = "Costs Lawyer's practising certificate (England & Wales)"
    licence.regulation_area = "Professional, legal and financial services" # Pick one from Licence.distinct(:regulation_area), or "Other"
    licence.save!

    ll = LicenceLink.new
    ll.licence = licence
    ll.sector_id = Sector.find_by(name: "Solicitor services").id
    ll.activity_id = Activity.find_by(name: "Offer professional legal services").id
    ll.save!
  end
end
