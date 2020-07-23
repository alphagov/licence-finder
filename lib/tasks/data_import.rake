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
end
