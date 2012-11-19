require 'data_importer'

namespace :import do
  desc "Import all records from the JSON files"
  task :all => ["import:sectors", "data_import:activities", "data_import:licences"]

  desc "Import all sector data"
  task :sector => :environment do
    DataImporter.import_for(Sector)
  end

  desc "Import all activity data"
  task :activity => :environment do
    DataImporter.import_for(Activity)
  end

  desc "Import all licence data"
  task :licence => :environment do
    DataImporter.import_for(Licence)
  end
end
