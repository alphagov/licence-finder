class DataFixes1 < Mongoid::Migration
  # See https://www.pivotaltracker.com/story/show/48322851
  def self.up
    # 1.
    l = Licence.find_by_gds_id("1180-8-1")
    l.gds_id = "1180-6-1"
    l.save!

    # 2
    l = Licence.find_by_gds_id("9072-7-1")
    l.gds_id = "380-6-1"
    l.da_northern_ireland = false
    l.save!

    # 3
    l = Licence.find_by_gds_id("9135-5-1")
    l.gds_id = "910-5-1"
    l.save!

    # 4
    l = Licence.find_by_gds_id("9170-3-1")
    l.gds_id = "910-3-1"
    l.save!

    # 5
    l = Licence.find_by_gds_id("694-5-1")
    l.gds_id = "694-1-1"
    l.name = "Hairdresser registration (England)"
    l.da_wales = false
    l.da_scotland = false
    l.save!

    l2 = Licence.new
    l2.gds_id = "694-2-1"
    l2.correlation_id = "9999990001" # Fake id because they're required to be unique, and 2 nil values violate that.
    l2.da_england = false
    l2.da_wales = true
    l2.da_scotland = false
    l2.da_northern_ireland = false
    l2.name = "Hairdresser registration (Wales)"
    l2.regulation_area = l.regulation_area
    l2.save!
    LicenceLink.where(:licence_id => l.id).each do |link|
      ll = LicenceLink.new
      ll.licence = l2
      ll.sector_id = link.sector_id
      ll.activity_id = link.activity_id
      ll.save!
    end

    # 6
    l = Licence.find_by_gds_id("9103-7-1")
    l.gds_id = "9103-6-1"
    l.da_northern_ireland = false
    l.name = "Registration of goat holdings (England, Wales and Scotland)"
    l.save!

    l2 = Licence.new
    l2.gds_id = "9103-4-1"
    l2.correlation_id = "9999990002"
    l2.da_england = false
    l2.da_wales = true
    l2.da_scotland = false
    l2.da_northern_ireland = false
    l2.name = "Registration of goat holdings (Northern Ireland)"
    l2.regulation_area = l.regulation_area
    l2.save!
    LicenceLink.where(:licence_id => l.id).each do |link|
      ll = LicenceLink.new
      ll.licence = l2
      ll.sector_id = link.sector_id
      ll.activity_id = link.activity_id
      ll.save!
    end
  end

  def self.down
  end
end
