require 'data_exporter'

namespace :export do
  desc "Export all records for all models"
  task :all => [:activity, :licence, :licence_link, :sector]

  desc "Export all Activity records to a local file in the /data/json folder"
  task :activity => :environment do
    DataExporter.export_for(Activity)
  end

  desc "Export all Licence records to a local file in the /data/json folder"
  task :licence => :environment do
    DataExporter.export_for(Licence)
  end

  desc "Export all LicenceLink records to a local file in the /data/json folder"
  task :licence_link => :environment do
    DataExporter.export_for(LicenceLink)
  end

  desc "Export all Sector records to a local file in the /data/json folder"
  task :sector => :environment do
    DataExporter.export_for(Sector)
  end
end
