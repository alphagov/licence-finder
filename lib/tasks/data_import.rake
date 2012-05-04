require 'data_importer'

desc "Import all data from the CSV files"
task :data_import => ["data_import:sectors", "data_import:activities"]

namespace :data_import do

  desc "Import all sector data"
  task :sectors => :environment do
    DataImporter::Sectors.update
  end

  desc "Import all activity data"
  task :activities => :environment do
    DataImporter::Activities.update
  end
end
