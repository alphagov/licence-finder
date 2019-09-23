class FoodPremisesApprovalLicenceWalesFixes < Mongoid::Migration
  def self.up
    # Food Premises Approval (England).
    english_licence = Licence.find_by_gds_id("1293-1-1")
    english_licence.da_england = true
    english_licence.da_wales = false
    english_licence.da_scotland = false
    english_licence.da_northern_ireland = false
    english_licence.save!

    # Food Premises Approval (Wales).
    welsh_licence = Licence.new
    welsh_licence.gds_id = "1293-2-1"
    welsh_licence.correlation_id = "9999990003" # Following the convention in `20130426141055_data_fixes1.rb`.
    welsh_licence.name = "Food Premises Approval (Wales)"
    welsh_licence.da_england = false
    welsh_licence.da_wales = true
    welsh_licence.da_scotland = false
    welsh_licence.da_northern_ireland = false
    welsh_licence.regulation_area = english_licence.regulation_area
    welsh_licence.save!
    LicenceLink.where(:licence_id => english_licence.id).each do |link|
      ll = LicenceLink.new
      ll.licence = welsh_licence
      ll.sector_id = link.sector_id
      ll.activity_id = link.activity_id
      ll.save!
    end

    # Food Premises Approval (Scotland).
    scottish_licence = Licence.new
    scottish_licence.gds_id = "1293-3-1"
    scottish_licence.correlation_id = "9999990004"
    scottish_licence.name = "Food Premises Approval (Scotland)"
    scottish_licence.da_england = false
    scottish_licence.da_wales = false
    scottish_licence.da_scotland = true
    scottish_licence.da_northern_ireland = false
    scottish_licence.regulation_area = english_licence.regulation_area
    scottish_licence.save!
    LicenceLink.where(:licence_id => english_licence.id).each do |link|
      ll = LicenceLink.new
      ll.licence = scottish_licence
      ll.sector_id = link.sector_id
      ll.activity_id = link.activity_id
      ll.save!
    end

    # Food Premises Approval (Northern Ireland).
    northern_irish_licence = Licence.new
    northern_irish_licence.gds_id = "1293-4-1"
    northern_irish_licence.correlation_id = "9999990005"
    northern_irish_licence.name = "Food Premises Approval (Northern Ireland)"
    northern_irish_licence.da_england = false
    northern_irish_licence.da_wales = false
    northern_irish_licence.da_scotland = false
    northern_irish_licence.da_northern_ireland = true
    northern_irish_licence.regulation_area = english_licence.regulation_area
    northern_irish_licence.save!
    LicenceLink.where(:licence_id => english_licence.id).each do |link|
      ll = LicenceLink.new
      ll.licence = northern_irish_licence
      ll.sector_id = link.sector_id
      ll.activity_id = link.activity_id
      ll.save!
    end
  end

  def self.down
  end
end
