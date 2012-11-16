namespace :create do
  desc "Create a new Activity entry and save it to the database"
  task :activity, [:name, :correlation_id] => :environment do |t, args|
    activity = Activity.create!(name: args[:name], correlation_id: args[:correlation_id])
    puts "Created activity: #{activity.inspect}" unless activity.nil?
  end

  desc "Create a new Licence entry and save it to the database"
  task :licence, [:name, :regulation_area, :gds_id] => :environment do |t, args|
    licence = Licence.create!(name: args[:name], regulation_area: args[:regulation_area], gds_id: args[:gds_id])
    puts "Created licence: #{licence.inspect}" unless licence.nil?
  end

  desc "Create a relationship between an Activity, Licence, and Sector and save it to the database"
  task :licence_link, [:activity_id, :licence_id, :sector_id] => :environment do |t, args|
    licence_link = LicenceLink.create!(
      activity_id: args[:activity_id], licence_id: args[:licence_id], sector_id: args[:sector_id])
    puts "Created licence link: #{licence_link.inspect}" unless licence_link.nil?
  end

  desc "Create a new Sector entry and save it to the database"
  task :sector, [:name, :layer, :correlation_id] => :environment do |t, args|
    sector = Sector.create!(name: args[:name], layer: args[:layer], correlation_id: args[:correlation_id])
    puts "Created sector: #{sector.inspect}" unless sector.nil?
  end
end
