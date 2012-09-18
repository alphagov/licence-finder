require 'data_importer'
require 'licence_data_migrator'

desc "Import all data from the CSV files"
task :data_import => ["data_import:sectors", "data_import:activities", "data_import:licences"]

namespace :data_import do
  desc "Import all data"
  task :all => :environment do
    DataImporter::Sectors.update
    DataImporter::Activities.update
    DataImporter::Licences.update
  end

  desc "Import all sector data"
  task :sectors => :environment do
    DataImporter::Sectors.update
  end

  desc "Import all activity data"
  task :activities => :environment do
    DataImporter::Activities.update
  end

  desc "Import all licence data"
  task :licences => :environment do
    DataImporter::Licences.update
    # Now migrate the imported licences to use the new gds_id
    LicenceDataMigrator.migrate
  end
end
