require 'data_importer'

namespace :import do
  desc "Import all records from the JSON files"
  task :all => ["import:sector", "import:activity", "import:licence", "import:licence_link"]

  desc "Import all activity data"
  task :activity => :environment do
    DataImporter.import_for(Activity)
  end

  desc "Import all licence data"
  task :licence => :environment do
    DataImporter.import_for(Licence)
  end

  desc "Import all licence data"
  task :licence_link => :environment do
    DataImporter.import_for(LicenceLink)
  end

  desc "Import all sector data"
  task :sector => :environment do
    DataImporter.import_for(Sector)
  end
end
